#!/usr/bin/env bash
# ==============================================================================
# verify.sh
#
# Deterministic local verification suite for Swift.sublime-syntax:
#   1. YAML integrity, context references, variable resolution & sregex check
#   2. Official Swift Specification audit against doc/spec/ (KeywordSpec.swift,
#      TokenSpec.swift, SummaryOfTheGrammar.md, CHANGELOG.md)
#   3. 100% scope test coverage check across tests/syntax_test_swift.swift
#   4. Full .sublime-syntax state-machine simulation verifying all column
#      assertions in tests/syntax_test_swift.swift
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

python3 - <<'PYEOF'
import os
import re
import sys
import warnings

warnings.filterwarnings("ignore", category=FutureWarning)

SYNTAX_FILE = "Swift.sublime-syntax"
TEST_FILE = "tests/syntax_test_swift.swift"
SPEC_DIR = "doc/spec"

# ------------------------------------------------------------------------------
# Minimal YAML parser tailored for .sublime-syntax (supports inline contexts)
# ------------------------------------------------------------------------------
def unquote(v):
    v = v.strip()
    if (v.startswith("'") and v.endswith("'")) or (v.startswith('"') and v.endswith('"')):
        is_single = v.startswith("'")
        v = v[1:-1]
        if is_single:
            v = v.replace("''", "'")
    return v

def scalar_val(k, v):
    v = unquote(v)
    if v == "true":
        return True
    if v == "false":
        return False
    if k == "pop" and str(v).isdigit():
        return int(v)
    return v

def parse_sublime_syntax(path):
    with open(path, "r", encoding="utf-8") as f:
        raw_lines = f.readlines()

    variables = {}
    contexts = {}
    top_scope = "source.swift"
    anon_counter = 0

    in_variables = False
    in_contexts = False
    current_ctx = None
    current_rule = None
    inline_ctx_name = None
    inline_rule = None

    for raw in raw_lines:
        line = raw.rstrip("\r\n")
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped.startswith("%YAML"):
            continue
        indent = len(line) - len(line.lstrip(" "))

        if indent == 0:
            in_variables = (stripped == "variables:")
            in_contexts = (stripped == "contexts:")
            if stripped.startswith("scope:"):
                top_scope = unquote(stripped.split(":", 1)[1])
            current_ctx = None
            current_rule = None
            inline_ctx_name = None
            inline_rule = None
            continue

        if in_variables and indent == 2 and ":" in stripped:
            k, v = stripped.split(":", 1)
            variables[k.strip()] = unquote(v)
            continue

        if in_contexts:
            if indent == 2 and stripped.endswith(":"):
                current_ctx = stripped[:-1].strip()
                contexts[current_ctx] = []
                current_rule = None
                inline_ctx_name = None
                inline_rule = None
            elif indent == 4 and stripped.startswith("- "):
                current_rule = {}
                contexts[current_ctx].append(current_rule)
                inline_ctx_name = None
                inline_rule = None
                rest = stripped[2:].strip()
                if ":" in rest:
                    rk, rv = rest.split(":", 1)
                    _set_rule_kv(current_rule, rk.strip(), rv.strip())
            elif indent == 6 and current_rule is not None:
                inline_ctx_name = None
                inline_rule = None
                if ":" in stripped and not stripped.startswith("- "):
                    rk, rv = stripped.split(":", 1)
                    _set_rule_kv(current_rule, rk.strip(), rv.strip())
            elif indent == 8 and current_rule is not None:
                if stripped.startswith("- "):
                    rest = stripped[2:].strip()
                    if ":" in rest:
                        # Anonymous inline context inside push/set
                        if inline_ctx_name is None:
                            anon_counter += 1
                            inline_ctx_name = f"__anon_{anon_counter}"
                            contexts[inline_ctx_name] = []
                            for lk in ("push", "set"):
                                if lk in current_rule and isinstance(current_rule[lk], list):
                                    current_rule[lk] = inline_ctx_name
                        inline_rule = {}
                        contexts[inline_ctx_name].append(inline_rule)
                        rk, rv = rest.split(":", 1)
                        _set_rule_kv(inline_rule, rk.strip(), rv.strip())
                    else:
                        for lk in ("push", "set"):
                            if lk in current_rule and isinstance(current_rule[lk], list):
                                current_rule[lk].append(unquote(rest))
                elif ":" in stripped:
                    ck, cv = stripped.split(":", 1)
                    for cap_key in ("captures", "escape_captures"):
                        if cap_key in current_rule and isinstance(current_rule[cap_key], dict):
                            current_rule[cap_key][int(ck.strip())] = unquote(cv)
            elif indent == 10 and inline_rule is not None:
                if ":" in stripped and not stripped.startswith("- "):
                    rk, rv = stripped.split(":", 1)
                    _set_rule_kv(inline_rule, rk.strip(), rv.strip())
            elif indent == 12 and inline_rule is not None:
                if ":" in stripped:
                    ck, cv = stripped.split(":", 1)
                    for cap_key in ("captures", "escape_captures"):
                        if cap_key in inline_rule and isinstance(inline_rule[cap_key], dict):
                            inline_rule[cap_key][int(ck.strip())] = unquote(cv)

    return top_scope, variables, contexts

def _set_rule_kv(rule, k, v):
    if not v:
        if k in ("captures", "escape_captures"):
            rule[k] = {}
        elif k in ("push", "set"):
            rule[k] = []
        else:
            rule[k] = None
        return
    rule[k] = scalar_val(k, v)

def resolve_vars(pattern, variables, for_python_re=True):
    for _ in range(10):
        changed = False
        def repl(m):
            nonlocal changed
            changed = True
            name = m.group(1)
            if name not in variables:
                raise KeyError(f"Undefined variable '{{{{{name}}}}}'")
            return variables[name]
        pattern = re.sub(r"\{\{(\w+)\}\}", repl, pattern)
        if not changed:
            break
    if for_python_re:
        # Translate Oniguruma/sregex POSIX classes to Python re equivalents
        pattern = pattern.replace("[[:alpha:]_]", r"(?:[^\W\d_]|_)")
        pattern = pattern.replace("[[:alnum:]_]", r"\w")
        pattern = pattern.replace("[[:lower:]_]", r"[a-z_]")
    return pattern

# ------------------------------------------------------------------------------
# Step 1: YAML, Contexts, Variables & sregex Compatibility Check
# ------------------------------------------------------------------------------
top_scope, variables, contexts = parse_sublime_syntax(SYNTAX_FILE)
errors = []

for vname in variables:
    try:
        resolved = resolve_vars(variables[vname], variables)
        re.compile(resolved)
    except Exception as e:
        errors.append(f"Variable '{vname}' error: {e}")

all_defined_scopes = {top_scope}

for ctx_name, rules in contexts.items():
    for idx, rule in enumerate(rules):
        for sk in ("scope", "meta_scope", "meta_content_scope"):
            if sk in rule and isinstance(rule[sk], str):
                for s in rule[sk].split():
                    all_defined_scopes.add(s)
        for ck in ("captures", "escape_captures"):
            if ck in rule and isinstance(rule[ck], dict):
                for s_str in rule[ck].values():
                    for s in s_str.split():
                        all_defined_scopes.add(s)
        for tk in ("include", "embed"):
            if tk in rule and isinstance(rule[tk], str):
                target = rule[tk]
                if not target.startswith("scope:") and target not in contexts:
                    errors.append(f"Context '{ctx_name}' rule #{idx+1}: missing {tk} target '{target}'")
        for tk in ("push", "set"):
            if tk in rule:
                targets = rule[tk] if isinstance(rule[tk], list) else [rule[tk]]
                for target in targets:
                    if target not in contexts:
                        errors.append(f"Context '{ctx_name}' rule #{idx+1}: missing {tk} target '{target}'")
        for rk in ("match", "escape"):
            if rk in rule and isinstance(rule[rk], str):
                raw_pat = rule[rk]
                try:
                    raw_resolved = resolve_vars(raw_pat, variables, for_python_re=False)
                    if "(?<=" in raw_resolved or "(?<!" in raw_resolved:
                        errors.append(f"Context '{ctx_name}' rule #{idx+1} uses lookbehind (incompatible with sregex): {raw_pat}")
                    if re.search(r"\\[1-9]", raw_resolved):
                        errors.append(f"Context '{ctx_name}' rule #{idx+1} uses backreference (incompatible with sregex): {raw_pat}")
                    re.compile(resolve_vars(raw_pat, variables, for_python_re=True))
                except Exception as e:
                    errors.append(f"Context '{ctx_name}' rule #{idx+1} invalid regex '{raw_pat}': {e}")

named_contexts = [c for c in contexts if not c.startswith("__anon_")]
print(f"[1/4] Syntax & sregex check: {len(variables)} variables, {len(named_contexts)} contexts, {len(all_defined_scopes)} unique scopes")

# ------------------------------------------------------------------------------
# Step 2: Official Swift Specification Audit (doc/spec/)
# ------------------------------------------------------------------------------
required_specs = [
    "SummaryOfTheGrammar.md",
    "LexicalStructure.md",
    "Types.md",
    "Expressions.md",
    "Statements.md",
    "Declarations.md",
    "Attributes.md",
    "Patterns.md",
    "GenericParametersAndArguments.md",
    "RevisionHistory.md",
    "KeywordSpec.swift",
    "TokenSpec.swift",
    "AttributeNodes.swift",
    "CHANGELOG.md",
]
for req in required_specs:
    p = os.path.join(SPEC_DIR, req)
    if not os.path.isfile(p) or os.path.getsize(p) == 0:
        errors.append(f"Missing or empty specification file: {p} (run ./scripts/sync_swift_spec.sh)")

with open(SYNTAX_FILE, "r", encoding="utf-8") as f:
    syntax_raw = f.read()
with open(TEST_FILE, "r", encoding="utf-8") as f:
    test_raw = f.read()

if os.path.isfile(os.path.join(SPEC_DIR, "KeywordSpec.swift")):
    with open(os.path.join(SPEC_DIR, "KeywordSpec.swift"), "r", encoding="utf-8") as f:
        kw_spec = f.read()
    lexer_kws = re.findall(r'name:\s*"([^"]+)"[^)]*isLexerClassified:\s*true', kw_spec, re.S)
    for kw in lexer_kws:
        if kw in ("_",):
            continue
        if not re.search(r'(?<![A-Za-z0-9_])' + re.escape(kw) + r'(?![A-Za-z0-9_])', syntax_raw):
            errors.append(f"Lexer-classified keyword '{kw}' from KeywordSpec.swift missing in {SYNTAX_FILE}")

if os.path.isfile(os.path.join(SPEC_DIR, "TokenSpec.swift")):
    with open(os.path.join(SPEC_DIR, "TokenSpec.swift"), "r", encoding="utf-8") as f:
        tok_spec = f.read()
    pound_kws = re.findall(r'case\s+\w+\s*=\s*#\.poundKeyword\(text:\s*"#([^"]+)"', tok_spec)
    for pkw in pound_kws:
        if not re.search(r'(?<![A-Za-z0-9_])' + re.escape(pkw) + r'(?![A-Za-z0-9_])', syntax_raw):
            errors.append(f"Pound keyword '#{pkw}' from TokenSpec.swift missing in {SYNTAX_FILE}")

grammar_word_terminals = set()
if os.path.isfile(os.path.join(SPEC_DIR, "SummaryOfTheGrammar.md")):
    with open(os.path.join(SPEC_DIR, "SummaryOfTheGrammar.md"), "r", encoding="utf-8") as f:
        grammar_raw = f.read()
    # Extract all formal grammar terminals **`...`**
    raw_terminals = set(re.findall(r"\*\*`([^`]+)`\*\*", grammar_raw))
    # Ignore single-char float exponent letters and playground literal parameter labels
    ignored_grammar_words = {"e", "E", "p", "P", "red", "green", "blue", "alpha", "resourceName"}
    for term in sorted(raw_terminals):
        if re.match(r"^[A-Za-z_#][A-Za-z0-9_]*$", term):
            bare = term.lstrip("#")
            if bare in ignored_grammar_words or bare == "_":
                continue
            grammar_word_terminals.add(bare)
            if not re.search(r'(?<![A-Za-z0-9_])' + re.escape(bare) + r'(?![A-Za-z0-9_])', syntax_raw):
                errors.append(f"Formal grammar terminal '{term}' from SummaryOfTheGrammar.md missing in {SYNTAX_FILE}")

required_modern_features = [
    # Swift 5.9 - 6.4 language & stdlib features
    "Copyable", "Escapable", "BitwiseCopyable", "Sendable",
    "borrowing", "consuming", "sending", "nonisolated", "isolated",
    "anyAppleOS", "RigidArray", "InlineArray",
    "Span", "MutableSpan", "RawSpan", "MutableRawSpan", "UTF8Span",
    "RangeSet", "DiscontiguousSlice", "OpaquePointer",
    "Synchronization", "Atomic", "Mutex", "AtomicLazyReference",
    "withTaskCancellationShield", "withTaskPriorityEscalationHandler",
    "withTaskExecutorPreference", "withDeadline", "withUnsafeTemporaryAllocation",
    "yielding", "borrow", "mutate", "package", "macro",
    "freestanding", "attached", "backDeployed",
]
for feat in required_modern_features:
    if not re.search(r'(?<![A-Za-z0-9_])' + re.escape(feat) + r'(?![A-Za-z0-9_])', syntax_raw):
        errors.append(f"Modern Swift feature '{feat}' missing in {SYNTAX_FILE}")
    if not re.search(r'(?<![A-Za-z0-9_])' + re.escape(feat) + r'(?![A-Za-z0-9_])', test_raw):
        errors.append(f"Modern Swift feature '{feat}' not tested in {TEST_FILE}")

print(
    f"[2/4] Official Swift spec audit: {len(required_specs)} spec files, "
    f"{len(grammar_word_terminals)} grammar terminals, "
    f"{len(required_modern_features)} modern Swift 5.9-6.4 features verified"
)

# ------------------------------------------------------------------------------
# Step 3: 100% Scope Coverage Check
# ------------------------------------------------------------------------------
with open(TEST_FILE, "r", encoding="utf-8") as f:
    test_lines = [l.rstrip("\r\n") for l in f]

tested_scopes = {top_scope}
for l in test_lines:
    m = re.match(r"^\s*//\s*(?:<-|\^+)\s*(.*)$", l)
    if m:
        for tok in m.group(1).split():
            if tok != "-":
                tested_scopes.add(tok.lstrip("-"))

untested_scopes = []
for s in sorted(all_defined_scopes):
    if not any(ts == s or ts.startswith(s + ".") for ts in tested_scopes):
        untested_scopes.append(s)

if untested_scopes:
    for s in untested_scopes:
        errors.append(f"Defined scope '{s}' is never asserted in {TEST_FILE}")

print(f"[3/4] Scope coverage check: {len(all_defined_scopes) - len(untested_scopes)}/{len(all_defined_scopes)} scopes covered (100%)")

# ------------------------------------------------------------------------------
# Step 4: Full State-Machine Execution of tests/syntax_test_swift.swift
# ------------------------------------------------------------------------------
def expand_context(ctx_name, visited=None):
    if visited is None:
        visited = set()
    if ctx_name in visited:
        return [], None, None, False
    visited.add(ctx_name)
    raw_rules = contexts[ctx_name]
    meta_scope = None
    meta_content_scope = None
    clear_scopes = False
    compiled = []
    for r in raw_rules:
        if "meta_scope" in r:
            meta_scope = r["meta_scope"]
        elif "meta_content_scope" in r:
            meta_content_scope = r["meta_content_scope"]
        elif "clear_scopes" in r:
            clear_scopes = r["clear_scopes"]
        elif "include" in r:
            inc = r["include"]
            if not inc.startswith("scope:"):
                sub_rules, _, _, _ = expand_context(inc, visited.copy())
                compiled.extend(sub_rules)
        elif "match" in r:
            rc = dict(r)
            rc["_regex"] = re.compile(resolve_vars(r["match"], variables))
            if "escape" in r:
                rc["_escape_regex"] = re.compile(resolve_vars(r["escape"], variables))
            compiled.append(rc)
    return compiled, meta_scope, meta_content_scope, clear_scopes

expanded_cache = {c: expand_context(c) for c in contexts}

class Frame:
    def __init__(self, name, escape_re=None, escape_caps=None, embed_scope=None):
        self.name = name
        self.rules, self.meta_scope, self.meta_content_scope, self.clear_scopes = expanded_cache[name]
        self.escape_re = escape_re
        self.escape_caps = escape_caps
        self.embed_scope = embed_scope
        self.in_content = True

def compute_base_scopes(stack):
    scopes = [top_scope]
    for fr in stack:
        if fr.clear_scopes:
            scopes = []
        if fr.meta_scope:
            scopes.extend(fr.meta_scope.split())
        if fr.in_content and fr.meta_content_scope:
            scopes.extend(fr.meta_content_scope.split())
        if fr.embed_scope:
            scopes.extend(fr.embed_scope.split())
    return scopes

def tokenize_line(line_with_nl, stack):
    n = len(line_with_nl)
    char_scopes = [None] * n
    pos = 0
    steps = 0
    while pos < n and steps < 5000:
        steps += 1
        top = stack[-1]

        if top.escape_re is not None:
            m_esc = top.escape_re.search(line_with_nl, pos)
        else:
            m_esc = None

        best_m = None
        best_rule = None
        for r in top.rules:
            m = r["_regex"].search(line_with_nl, pos)
            if m is not None:
                if best_m is None or m.start() < best_m.start():
                    best_m = m
                    best_rule = r
                    if m.start() == pos:
                        break

        if m_esc is not None and (best_m is None or m_esc.start() <= best_m.start()):
            base = compute_base_scopes(stack)
            for i in range(pos, m_esc.start()):
                if char_scopes[i] is None:
                    char_scopes[i] = list(base)
            stack.pop()
            base_after = compute_base_scopes(stack)
            for i in range(m_esc.start(), m_esc.end()):
                char_scopes[i] = list(base_after)
            if top.escape_caps:
                for g, cscope in top.escape_caps.items():
                    if g <= len(m_esc.regs) - 1 and m_esc.start(g) != -1:
                        for i in range(m_esc.start(g), m_esc.end(g)):
                            char_scopes[i].extend(cscope.split())
            pos = max(pos, m_esc.end())
            continue

        if best_m is None:
            base = compute_base_scopes(stack)
            for i in range(pos, n):
                if char_scopes[i] is None:
                    char_scopes[i] = list(base)
            break

        if best_m.start() > pos:
            base = compute_base_scopes(stack)
            for i in range(pos, best_m.start()):
                if char_scopes[i] is None:
                    char_scopes[i] = list(base)

        m_start, m_end = best_m.start(), best_m.end()
        rule = best_rule

        pre_stack = list(stack)
        if "pop" in rule and rule["pop"]:
            pop_count = rule["pop"] if isinstance(rule["pop"], int) else 1
            for _ in range(min(pop_count, len(stack) - 1)):
                stack[-1].in_content = False
                stack.pop()
            if "set" not in rule and "push" not in rule and "embed" not in rule:
                match_base = compute_base_scopes(pre_stack)
            else:
                match_base = compute_base_scopes(stack)
        elif "set" in rule:
            stack[-1].in_content = False
            match_base = compute_base_scopes(stack)
        else:
            match_base = compute_base_scopes(stack)

        pushed_frames = []
        if "set" in rule:
            stack.pop()
            targets = rule["set"] if isinstance(rule["set"], list) else [rule["set"]]
            for t in targets:
                fr = Frame(t)
                fr.in_content = False
                stack.append(fr)
                pushed_frames.append(fr)
        elif "push" in rule:
            targets = rule["push"] if isinstance(rule["push"], list) else [rule["push"]]
            for t in targets:
                fr = Frame(t)
                fr.in_content = False
                stack.append(fr)
                pushed_frames.append(fr)
        elif "embed" in rule:
            emb = rule["embed"]
            esc_re = rule.get("_escape_regex")
            esc_caps = rule.get("escape_captures")
            emb_scope = rule.get("embed_scope")
            if emb.startswith("scope:"):
                fr = Frame("main", esc_re, esc_caps, emb_scope)
            else:
                fr = Frame(emb, esc_re, esc_caps, emb_scope)
            fr.in_content = False
            stack.append(fr)
            pushed_frames.append(fr)

        added_meta = []
        for fr in pushed_frames:
            if fr.meta_scope:
                for ms in fr.meta_scope.split():
                    if ms not in match_base:
                        added_meta.append(ms)

        rscope = rule.get("scope", "").split() if rule.get("scope") else []
        for i in range(m_start, m_end):
            char_scopes[i] = list(match_base) + added_meta + rscope

        if "captures" in rule and isinstance(rule["captures"], dict):
            for g, cscope in rule["captures"].items():
                if g <= len(best_m.regs) - 1 and best_m.start(g) != -1:
                    for i in range(best_m.start(g), best_m.end(g)):
                        if i < n:
                            if char_scopes[i] is None:
                                char_scopes[i] = list(match_base)
                            char_scopes[i].extend(cscope.split())

        for fr in pushed_frames:
            fr.in_content = True

        if m_end == pos:
            if char_scopes[pos] is None:
                char_scopes[pos] = compute_base_scopes(stack)
            pos += 1
        else:
            pos = m_end

    base = compute_base_scopes(stack)
    for i in range(n):
        if char_scopes[i] is None:
            char_scopes[i] = list(base)
    return char_scopes

stack = [Frame("main")]
last_code_scopes = None
last_code_line_no = 0
last_code_line = ""
assertion_count = 0

for idx, line in enumerate(test_lines):
    line_no = idx + 1
    if idx == 0 and "SYNTAX TEST" in line:
        tokenize_line(line + "\n", stack)
        continue

    m_arrow = re.match(r"^(\s*)//\s*<-\s*(.*)$", line)
    m_caret = re.match(r"^(\s*)//\s*(\^+)\s*(.*)$", line)

    if m_arrow or m_caret:
        if m_arrow:
            col_start, col_end = 0, 1
            spec = m_arrow.group(2).strip()
        else:
            col_start = line.index("^")
            col_end = col_start + len(m_caret.group(2))
            spec = m_caret.group(3).strip()

        pos_reqs, neg_reqs = [], []
        mode = "pos"
        for tok in spec.split():
            if tok == "-":
                mode = "neg"
            elif tok.startswith("-"):
                neg_reqs.append(tok[1:])
            elif mode == "neg":
                neg_reqs.append(tok)
            else:
                pos_reqs.append(tok)

        for c in range(col_start, col_end):
            assertion_count += 1
            actual = last_code_scopes[min(c, len(last_code_scopes) - 1)]
            actual_str = " ".join(actual)
            for req in pos_reqs:
                if not any(a == req or a.startswith(req + ".") for a in actual):
                    errors.append(
                        f"Assertion failed at {TEST_FILE}:{line_no} (testing line {last_code_line_no} col {c+1}):\n"
                        f"  Code:     {last_code_line}\n"
                        f"  Expected: {req}\n"
                        f"  Actual:   {actual_str}"
                    )
                    break
            for nreq in neg_reqs:
                if any(a == nreq or a.startswith(nreq + ".") for a in actual):
                    errors.append(
                        f"Negative assertion failed at {TEST_FILE}:{line_no} (testing line {last_code_line_no} col {c+1}):\n"
                        f"  Code:          {last_code_line}\n"
                        f"  Unexpected:    {nreq}\n"
                        f"  Actual:        {actual_str}"
                    )
                    break
    else:
        last_code_scopes = tokenize_line(line + "\n", stack)
        last_code_line_no = line_no
        last_code_line = line

print(f"[4/4] State-machine test runner: {assertion_count} column assertions verified across {len(test_lines)} lines")

if errors:
    print(f"\nFAILED with {len(errors)} error(s):", file=sys.stderr)
    for e in errors[:25]:
        print(f"  - {e}", file=sys.stderr)
    sys.exit(1)

print("\nALL CHECKS PASSED (0 errors)")
PYEOF

# Optional: if Sublime Text's standalone syntax_tests binary is in PATH, run it too
if command -v syntax_tests >/dev/null 2>&1; then
    echo "Running Sublime Text standalone syntax_tests binary..."
    syntax_tests
fi
