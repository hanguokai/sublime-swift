# Swift Package Maintenance Guide

This document describes the repository architecture, supported Swift language features, **Sublime Text `.sublime-syntax` authoring guidelines**, specification-driven verification workflow, and release process for the **`Swift`** package (`sublime-swift`).

---

## 1. Architecture & Supported Features

### 1.1 Directory Structure

```text
sublime-swift/
├── .github/
│   └── workflows/
│       └── syntax-tests.yml           # GitHub Actions CI: runs ./scripts/verify.sh + official ST3 (3211) & ST4 (stable/latest) syntax tests
├── Swift.sublime-syntax               # Core grammar: ST3 (>=3092) & ST4 (sregex) compatible Swift syntax definition
├── Comments.tmPreferences             # Comment preferences: Cmd+/ line comments & Cmd+Opt+/ block comments
├── Indentation.tmPreferences          # Indentation rules: auto-indent for {}, [], (), and switch case/default
├── Symbol List.tmPreferences          # Symbol indexing: Cmd+R / Cmd+Shift+R navigation for types, functions, macros, etc.
├── Symbol List - Marks.tmPreferences  # MARK navigation: formats // MARK: - xxx as section headers in Cmd+R
├── tests/
│   └── syntax_test_swift.swift        # Official Sublime Text scope assertion test suite (100% coverage of all defined scopes)
├── scripts/
│   ├── install_macos.sh               # macOS symlink installer for local development in Sublime Text
│   ├── sync_swift_spec.sh             # Syncs official Swift grammar & lexical spec files into doc/spec/
│   └── verify.sh                      # Deterministic local verification suite (sregex check + spec audit + 100% scope coverage + state-machine runner)
├── doc/
│   ├── MAINTENANCE.md                 # This maintenance guide (excluded from release archives via .gitattributes)
│   └── spec/                          # Local mirror of official Swift language reference, EBNF grammar, compiler token tables & CHANGELOG
│       ├── SummaryOfTheGrammar.md     # Full official EBNF grammar extracted from the 8 ReferenceManual chapters
│       ├── LexicalStructure.md        # Official lexical structure spec (identifiers, literals, operators, escapes)
│       ├── Types.md                   # Official type syntax spec
│       ├── Expressions.md             # Official expression syntax spec
│       ├── Statements.md              # Official statement & compiler control spec
│       ├── Declarations.md            # Official declaration & modifier spec
│       ├── Attributes.md              # Official attributes (@available, @attached, @freestanding, etc.) spec
│       ├── Patterns.md                # Official pattern matching spec
│       ├── GenericParametersAndArguments.md # Official generic parameters & ~Copyable/~Escapable/~Sendable spec
│       ├── RevisionHistory.md         # TSPL official revision history
│       ├── KeywordSpec.swift          # swift-syntax compiler keyword table
│       ├── TokenSpec.swift            # swift-syntax compiler token & #pound keyword table
│       ├── AttributeNodes.swift       # swift-syntax compiler built-in attribute table
│       └── CHANGELOG.md               # Official apple/swift compiler changelog (through Swift 6.3 / 6.4 / Next)
├── .gitattributes                     # Excludes .github/, tests/, scripts/, doc/, etc. from git archive release packages
├── .gitignore                         # Ignores cache files and build artifacts
├── LICENSE                            # MIT License
└── README.md                          # Package documentation rendered on GitHub and Package Control
```

> **Packaging Note**: Via `export-ignore` rules in [`.gitattributes`](../.gitattributes), `.github/`, `tests/`, `scripts/`, `doc/` (including `doc/spec/`), `.gitignore`, and `.gitattributes` are automatically excluded when GitHub generates release archives for tags. End users installing via Package Control download only the 7 core files in the repository root.

---

### 1.2 Supported Language Features (Swift 5.x – 6.4)

| Area | Supported Syntax | Core Scopes |
| :--- | :--- | :--- |
| **Concurrency & Isolation** | `async`, `reasync`, `await`, `actor`, `distributed actor`, `sending`, `isolated`, `isolated deinit` (SE-0371), `nonisolated`, `nonisolated(unsafe)`, `nonisolated(nonsending)` (SE-0461), `#isolation`, `@isolated(any)`, `@MainActor`, `@Sendable`, `~Sendable` (SE-0518), `Sendable`, `SendableMetatype`, `withTaskCancellationShield` (SE-0504), `withTaskPriorityEscalationHandler` (SE-0462), `withTaskExecutorPreference`, `withDeadline` | `storage.modifier.async.swift`, `storage.modifier.concurrency.swift`, `storage.type.actor.swift`, `keyword.control.flow.await.swift`, `variable.language.isolation.swift`, `support.function.builtin.swift` |
| **Macros** | `macro` declarations, `@freestanding(expression/declaration)`, `@attached(member/peer/accessor/memberAttribute/extension/body/preamble)` (including nested arguments like `names: named(init)`), `#externalMacro`, and freestanding macro expansions (`#expect`, `#require`, `#Preview`, `#Predicate`, and module-qualified `#Module.macro(...)`) | `storage.type.macro.swift`, `entity.name.function.macro.swift`, `variable.annotation.macro.swift`, `support.function.macro.swift` |
| **Error Handling** | Swift 6 typed throws `throws(ErrorType)`, `do throws(ErrorType) { ... } catch`, untyped `throws` / `rethrows`, `do` / `try` / `try?` / `try!` / `catch` / `throw` | `keyword.control.exception.throws.swift`, `meta.throws.typed.swift`, `keyword.control.exception.swift` |
| **Ownership & Suppressed Constraints** | `~Copyable`, `~Escapable`, `~BitwiseCopyable`, `~Sendable` (Swift 6.4 SE-0518), `borrowing`, `consuming`, `inout`, `yielding`, `consume`, `copy`, `discard self`, `unsafe` expression operator, and Swift 6.4 `borrow` / `mutate` accessors (SE-0474) | `meta.generic-constraint.suppressed.swift`, `keyword.operator.tilde.suppressed.swift`, `support.type.protocol.suppressed.swift`, `storage.modifier.ownership.swift`, `keyword.operator.word.ownership.swift`, `keyword.operator.word.unsafe.swift`, `keyword.other.accessor.swift` |
| **Generics, Metatypes & Operators** | `some Protocol`, `any Protocol`, `<let N: Int>` value generic parameters (SE-0452), `[N of Element]` (`InlineArray` type sugar), parameter packs `each T` and `repeat each x`, explicit metatypes and self references `.Type` / `.Protocol` / `.self`, and `precedencegroup` attributes (`higherThan`, `lowerThan`, `associativity: left/right/none`, `assignment`) | `storage.modifier.type.swift`, `keyword.operator.word.swift`, `keyword.operator.pack.swift`, `variable.language.swift`, `keyword.other.operator.precedence.swift`, `constant.language.precedence.swift` |
| **Access Control, Availability & Modules** | `open`, `public`, `package`, `internal`, `fileprivate`, `private` (including `...(set)` forms), Swift 6 access-level imports `public/package/... import`, module selectors `Module::symbol` (SE-0491), `@diagnose` custom diagnostic attributes (SE-0522), and `#if` / `#available` / `#unavailable` / `@available` / `@backDeployed` platform & version arguments (including Swift 6.4 `anyAppleOS`, `visionOS`, `introduced`, `deprecated`, `obsoleted`, `unavailable`, `noasync`, `before`, etc.) | `storage.modifier.access-control.swift`, `keyword.control.import.swift`, `punctuation.accessor.module.swift`, `meta.availability.swift`, `support.constant.directive.swift`, `support.constant.attribute.availability.swift` |
| **Literals, Raw Identifiers & Regex** | Binary `0b` / octal `0o` / hex `0x` / decimal integer & float literals, single-line & multiline strings `"""..."""` (including escaped trailing newlines `\[ \t]*\n`), raw strings `#"..."#` & interpolations `\#(...)`, raw identifiers `` `raw name` `` / `` `$raw property` `` (SE-0451), single-line regex `/.../`, and extended multiline regex `#/.../#` | `constant.numeric.*.swift`, `string.quoted.*.swift`, `meta.interpolation.swift`, `string.regexp.*.swift`, `variable.function.swift`, `variable.other.projected.swift` |
| **Comments & Navigation Marks** | Single-line comments `//`, documentation comments `///` and `/** ... */`, nested block comments `/* /* ... */ */`, and Xcode-style `// MARK: -` / `TODO:` / `FIXME:` | `comment.*.swift`, `entity.name.section.mark.swift` |
| **Standard Library Types & Functions** | Includes Swift 6.0–6.4 types and functions such as `RigidArray`, `InlineArray`, `UniqueArray`, `UniqueBox`, `Span`, `RawSpan`, `MutableSpan`, `MutableRawSpan`, `OutputSpan`, `OutputRawSpan`, `UTF8Span`, `RangeSet`, `DiscontiguousSlice`, `OpaquePointer`, `Ref`, `MutableRef`, `Mutex`, `Atomic`, `AtomicLazyReference`, `Regex`, `Iterable`, `BorrowingIteratorProtocol`, `ObservationRegistrar`, `EncodingError`, `DecodingError`, `CancellationError`, `Int128`, `UInt128`, `withUnsafeTemporaryAllocation`, etc. | `support.type.swift`, `support.function.builtin.swift` |

---

## 2. `.sublime-syntax` Authoring Guidelines & Pitfalls

Follow these core rules whenever modifying [`Swift.sublime-syntax`](../Swift.sublime-syntax):

### 2.1 Never Use Lookbehinds (`(?<=...)` or `(?<!...)`)
- **Why**: Sublime Text 4's high-performance DFA regex engine (`sregex`) **does not support positive or negative lookbehinds**. Any rule containing `(?<=` or `(?<!` forces Sublime Text to fall back to the slower Oniguruma engine.
- **Workaround**: Replace lookbehinds with preceding consumption rules or positive/negative lookaheads `(?=...)` / `(?!...)`:
  - In extended regex literals `#/.../#`, match `- match: '\\.'` first to consume escaped characters so the next rule can match unescaped `#` comments without `(?<!\\)#`.
  - In single-line regex literals `/.../`, use `((?:[^/\r\n\\\s]|\\.)(?:(?:[^/\r\n\\]|\\.)*(?:[^/\r\n\\\s]|\\.))?)` to require non-whitespace at both ends without a trailing `(?<!\s)`.
- **Verification**:
  1. Run `./scripts/verify.sh` (automatically scans all expanded patterns for `(?<=`, `(?<!`, and `\1`..`\9` backreferences).
  2. Open `$HOME/Library/Application Support/Sublime Text/Packages/Swift/Swift.sublime-syntax` in Sublime Text and run **`Build With: Syntax Tests - Regex Compatibility`** (`Success: all patterns ... are compatible with the new regex engine`).
  3. Or run in the Sublime Text console (`` Ctrl+` ``):
     ```python
     import sublime_api; sublime_api.incompatible_syntax_patterns("Packages/Swift/Swift.sublime-syntax")
     ```
     An empty list `[]` confirms 100% `sregex` compatibility.

### 2.2 Guard Contextual Keywords Against Identifier False Positives
- **Why**: Many modern Swift keywords (`package`, `borrowing`, `consuming`, `sending`, `isolated`, `distributed`, `some`, `any`, `each`, `consume`, `copy`, `unsafe`, `borrow`, `mutate`) are contextual and frequently appear as variable names, parameter names, or member properties (e.g., `let package = 1`, `for each in items`, `worker.sending`, `worker.borrowing()`).
- **How to guard**:
  1. Match dot-member access `(\.)([[:lower:]_]{{ident_char}}*)` and backtick identifiers `` `[^`\\\r\n]+` `` in `declarations` *before* contextual modifiers so `worker.sending` or `worker.borrowing()` are consumed first.
  2. Require strict lookaheads on contextual modifiers:
     - `each`: `\b(each)\b(?=\s+{{ident}})(?!\s*(?:[:=]|\b(?:in|as|is|where|else|catch)\b))` (matches `each T`, while excluding `for each in list`, `if each is Int`, etc.).
     - `package`: only highlight as an access-control modifier when followed by a declaration keyword (`struct`, `class`, `func`, `import`, `var`, `let`, `deinit`, etc.) or modifier chain (`{{decl_follow}}`), leaving `let package = 1` untouched.

### 2.3 Always Balance Nested Parentheses `\(` in `push` Contexts
- **Pitfall**: In contexts such as `@attached(member, names: named(init), arbitrary)` or `@available(...)`, if the pushed context only pops on `\)`, the closing parenthesis of `named(init)` pops the outer attribute context early.
- **Rule**: Any context pushed by `\(` and popped by `\)` (`availability-args`, `macro-attribute-args`, `interpolation-body`) **must** include a rule matching `\(` that pushes a nested parenthesis context so inner parentheses are balanced.

### 2.4 Use Explicit Branches for Raw Strings Instead of `\1` Backreferences
- Because `sregex` does not support backreferences (`\1`), raw strings (`#"..."#`, `##"..."##`, `###+"..."###+`) are written as explicit branches by hash count, and `./scripts/verify.sh` rejects any `\1`..`\9` backreferences.

### 2.5 Never Place Variable-Length Captures Directly Before Negative Lookaheads; Match Keyword Labels by Leading Delimiters
- **Pitfall**: Adding a negative lookahead directly after `({{ident}})` (such as `\b(enum)\s+({{ident}})(?!\s*:\s*[^{};\r\n]*\))`) allows the regex engine to backtrack and shorten `{{ident}}` by one character so the lookahead succeeds (highlighting `enum Kind: String // (a, b)` as `Kin`).
- **Rules**:
  1. Never place a negative lookahead directly after a variable-length capture like `({{ident}})` unless the lookahead starts with `\b` or a disjoint character class.
  2. Keywords used as argument/parameter labels (`f(default: 1)`, `dict[k, default: 0]`, `func f(in ctx: C, class k: Int)`) are handled at the top of `declarations` by consuming the leading `(`, `[`, or `,` before `{{label_keyword}}`. Do not attach line-end `)` heuristics to keywords like `case`, `where`, `default`, or `each`.
  3. Known limitation: In multiline parameter lists, a line-leading `class k: Int` or `for item: T` cannot be distinguished from a declaration or statement without lookbehinds (except `in` and `default`, since `in x:` and `default x:` are never valid statements).

### 2.6 Preserve Sublime Text 3 (`>=3092`) Compatibility
- Do not add `version: 2` or ST4-only YAML directives (`branch_point`, `branch`, `fail`, `embed`, `escape`, `extends`, `set`, or integer `pop: N`) unless creating a dedicated ST4-only release branch. Keeping the syntax free of ST4-only directives allows the same file to run on both Sublime Text 3 (`>=3092`) and Sublime Text 4 (`sregex`).

---

## 3. Specification-Driven Verification Workflow

> **Note for Maintainers and AI Coding Assistants**: Do not rely on LLM memory alone when adding or modifying Swift syntax rules. Always follow this three-step deterministic workflow:

### 3.1 Sync & Consult the Official Swift Specification (`doc/spec/`)
When a new Swift version is released, run the sync script to fetch the latest grammar and token definitions from Apple's official repositories:
```bash
./scripts/sync_swift_spec.sh
```
This script syncs and generates from `swiftlang/swift-book`, `swiftlang/swift-syntax`, and `swiftlang/swift`:
- **`doc/spec/SummaryOfTheGrammar.md`**: Full official EBNF grammar productions extracted from the eight `ReferenceManual` chapters.
- **`doc/spec/LexicalStructure.md` / `Declarations.md` / `Attributes.md` / `Types.md` / `Expressions.md` / `Statements.md` / `Patterns.md` / `GenericParametersAndArguments.md`**: Complete official language reference chapters.
- **`doc/spec/KeywordSpec.swift`, `TokenSpec.swift`, & `AttributeNodes.swift`**: Authoritative keyword, token, and attribute definitions from `swift-syntax`.
- **`doc/spec/CHANGELOG.md`**: Official Swift compiler changelog with concrete syntax examples for every SE proposal.

### 3.2 Run the Local Verification Suite (`./scripts/verify.sh`)
After any change to `Swift.sublime-syntax` or `tests/syntax_test_swift.swift`, run:
```bash
./scripts/verify.sh
```
`verify.sh` performs four deterministic checks:
1. **Syntax Integrity & `sregex` Check**: Verifies variable expansion, context references, 0 lookbehinds (`(?<=` / `(?<!`), and 0 backreferences (`\1`..`\9`).
2. **Official Swift Specification Audit**: Parses `doc/spec/SummaryOfTheGrammar.md` (all EBNF word terminals), `doc/spec/KeywordSpec.swift` (all `isLexerClassified: true` keywords), `doc/spec/TokenSpec.swift` (all `#pound` keywords), and the modern Swift 5.9–6.4 feature list to ensure none are missing in `Swift.sublime-syntax` or `tests/syntax_test_swift.swift`.
3. **100% Scope Coverage Check**: Extracts every scope defined in `Swift.sublime-syntax` and verifies that each scope is asserted at least once in `tests/syntax_test_swift.swift`.
4. **State-Machine Test Runner**: Simulates Sublime Text's `push`/`pop`/`include`/`meta_scope`/`meta_content_scope`/`clear_scopes` state machine across all positive and negative column assertions in `tests/syntax_test_swift.swift`.

### 3.3 Local Installation & GitHub Actions CI
- **Local Development**: Run `./scripts/install_macos.sh` to symlink `~/Library/Application Support/Sublime Text/Packages/Swift` to this repository. Sublime Text hot-reloads changes on save.
- **Switching Back to Package Control**: Remove the symlink before installing the packaged version from Package Control to avoid duplicate syntax files:
  ```bash
  rm "$HOME/Library/Application Support/Sublime Text/Packages/Swift"
  ```
- **Sublime Text Built-in Syntax Tests**: Open the target file via the `Packages/Swift` symlink path and run the corresponding build target from the Command Palette (`Cmd+Shift+P`):
  - **Scope Assertions (`Build With: Syntax Tests`)**:
    ```bash
    subl "$HOME/Library/Application Support/Sublime Text/Packages/Swift/tests/syntax_test_swift.swift"
    ```
  - **Regex Compatibility (`Build With: Syntax Tests - Regex Compatibility`)**:
    ```bash
    subl "$HOME/Library/Application Support/Sublime Text/Packages/Swift/Swift.sublime-syntax"
    ```
- **GitHub Actions CI**: [`.github/workflows/syntax-tests.yml`](../.github/workflows/syntax-tests.yml) runs `./scripts/verify.sh` and `SublimeText/syntax-test-action@v2` across ST3 (`3211`) and ST4 (`stable` and `latest`) on every push and pull request.
- **Inspect Scope at Cursor**: Press **`Ctrl+Opt+Cmd+P`** (macOS) in Sublime Text to inspect the full scope stack at the cursor.

---

## 4. Release & Git Workflow

This repository serves the **`Swift`** package in Package Control Channel (`sublimehq/package_control_channel`). The legacy ST2 snapshot (`v0.0.9`) is preserved on the orphan `st2` branch under tag `st2-0.0.9` for `<3092` builds, while `>=3092` (ST3 and ST4) builds track SemVer tags on `main`:

```json
{
	"name": "Swift",
	"details": "https://github.com/hanguokai/sublime-swift",
	"labels": ["language syntax", "swift"],
	"releases": [
		{
			"sublime_text": "<3092",
			"tags": "st2-"
		},
		{
			"sublime_text": ">=3092",
			"tags": true
		}
	]
}
```

### Standard Release Steps
Because `"tags": true` is configured for `>=3092`, new releases are published automatically by pushing a SemVer tag to GitHub (no Package Control PR required):

1. **Verify all checks pass locally**:
   ```bash
   ./scripts/verify.sh
   ```
2. **Commit changes and push a new SemVer tag on the tip of `main`**:
   > **Note**: Package Control's review bot checks whether the latest tag trails the tip of `main` (`Latest version is X commits behind tip of main`). When cutting a release, always place the new tag on the latest commit.
   ```bash
   git add .
   git commit -m "Describe your changes..."
   git tag -a 1.0.7 -m "Release 1.0.7"
   git push origin main --tags
   ```
3. **Verify release archive contents (optional)**:
   ```bash
   git archive --format=tar HEAD | tar -t
   ```
