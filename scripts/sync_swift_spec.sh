#!/usr/bin/env bash
# ==============================================================================
# Sync Official Swift Language Specifications & Compiler Token Definitions
# ==============================================================================
# Downloads authoritative Swift grammar, lexical structure, attribute reference,
# SwiftSyntax keyword/token specs, and the official Swift CHANGELOG into
# doc/spec/ for deterministic local reference and grammar auditing.
#
# Sources:
#   1. swiftlang/swift-book (TSPL ReferenceManual & RevisionHistory)
#   2. swiftlang/swift-syntax (KeywordSpec.swift, TokenSpec.swift, AttributeNodes.swift)
#   3. swiftlang/swift (CHANGELOG.md)
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC_DIR="$REPO_DIR/doc/spec"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

SWIFT_BOOK_REF="${SWIFT_BOOK_REF:-main}"
SWIFT_SYNTAX_REF="${SWIFT_SYNTAX_REF:-main}"
SWIFT_COMPILER_REF="${SWIFT_COMPILER_REF:-main}"

SWIFT_BOOK_BASE="https://raw.githubusercontent.com/swiftlang/swift-book/${SWIFT_BOOK_REF}/TSPL.docc"
SWIFT_SYNTAX_BASE="https://raw.githubusercontent.com/swiftlang/swift-syntax/${SWIFT_SYNTAX_REF}/CodeGeneration/Sources/SyntaxSupport"
SWIFT_COMPILER_BASE="https://raw.githubusercontent.com/swiftlang/swift/${SWIFT_COMPILER_REF}"

mkdir -p "$SPEC_DIR"

fetch_file() {
    local url="$1"
    local dest="$2"
    local label="$3"
    printf "  -> Fetching %-36s ... " "$label"
    if curl -fsSL --retry 3 --retry-delay 1 "$url" -o "$TMP_DIR/$(basename "$dest")"; then
        mv "$TMP_DIR/$(basename "$dest")" "$dest"
        local bytes
        bytes="$(wc -c < "$dest" | tr -d ' ')"
        printf "OK (%s bytes)\n" "$bytes"
    else
        printf "FAILED\n" >&2
        echo "Error: Failed to download $url" >&2
        return 1
    fi
}

echo "==> Syncing Swift Language Reference (swiftlang/swift-book @ ${SWIFT_BOOK_REF})..."
REFERENCE_CHAPTERS=(
    "LexicalStructure.md"
    "Types.md"
    "Expressions.md"
    "Statements.md"
    "Declarations.md"
    "Attributes.md"
    "Patterns.md"
    "GenericParametersAndArguments.md"
)

for chapter in "${REFERENCE_CHAPTERS[@]}"; do
    fetch_file "${SWIFT_BOOK_BASE}/ReferenceManual/${chapter}" "$SPEC_DIR/${chapter}" "ReferenceManual/${chapter}"
done

fetch_file "${SWIFT_BOOK_BASE}/RevisionHistory/RevisionHistory.md" "$SPEC_DIR/RevisionHistory.md" "RevisionHistory/RevisionHistory.md"

echo "==> Generating SummaryOfTheGrammar.md from ReferenceManual chapters..."
SUMMARY_FILE="$SPEC_DIR/SummaryOfTheGrammar.md"
{
    cat << 'EOF'
# Summary of the Grammar

Read the whole formal grammar.

This file is automatically extracted from the formal `> Grammar of ...:` blocks
across the 8 Reference Manual chapters of *The Swift Programming Language*
(`swiftlang/swift-book`), matching upstream `bin/generate-grammar`.

EOF
    for chapter in "${REFERENCE_CHAPTERS[@]}"; do
        awk '
            /^# / { sub(/^# /, "## "); print; print "" }
            /^> Grammar of / { in_grammar = 1 }
            in_grammar && /^>/ { print }
            in_grammar && !/^>/ { print ""; in_grammar = 0 }
            END { if (in_grammar) print "" }
        ' "$SPEC_DIR/${chapter}"
    done
} > "$SUMMARY_FILE"
printf "  -> Generated %-35s ... OK (%s bytes)\n" "SummaryOfTheGrammar.md" "$(wc -c < "$SUMMARY_FILE" | tr -d ' ')"

echo "==> Syncing SwiftSyntax Token & Keyword Specs (swiftlang/swift-syntax @ ${SWIFT_SYNTAX_REF})..."
SYNTAX_SPECS=(
    "KeywordSpec.swift"
    "TokenSpec.swift"
    "AttributeNodes.swift"
)

for spec in "${SYNTAX_SPECS[@]}"; do
    fetch_file "${SWIFT_SYNTAX_BASE}/${spec}" "$SPEC_DIR/${spec}" "SyntaxSupport/${spec}"
done

echo "==> Syncing Swift Compiler & Stdlib Changelog (swiftlang/swift @ ${SWIFT_COMPILER_REF})..."
fetch_file "${SWIFT_COMPILER_BASE}/CHANGELOG.md" "$SPEC_DIR/CHANGELOG.md" "swift/CHANGELOG.md"

echo "==> Done! All official Swift specifications synced to: $SPEC_DIR"
