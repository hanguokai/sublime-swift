# Swift6 for Sublime Text 4

Modern, lightweight **Swift 6** syntax highlighting and symbol navigation for **Sublime Text 4**.

Built from scratch using Sublime Text 4's `version: 2` `.sublime-syntax` engine and official [Scope Naming Guidelines](https://www.sublimetext.com/docs/scope_naming.html), providing complete support for Swift 5.7 through Swift 6.x language features.

---

## Features

- **Modern Swift 6 (up to Swift 6.4) Syntax Highlighting**:
  - **Concurrency & Isolation**: `async`, `await`, `actor`, `distributed actor`, `sending`, `isolated`, `isolated deinit`, `nonisolated`, `nonisolated(unsafe)`, `nonisolated(nonsending)`, `#isolation`, `@isolated(any)`, `@MainActor`, `@Sendable`, `~Sendable`, `Sendable`, `SendableMetatype`, `withTaskCancellationShield`, `withTaskPriorityEscalationHandler`, `withTaskExecutorPreference`, `withDeadline`
  - **Macros**: `macro` declarations, `@freestanding(expression/declaration)`, `@attached(member/peer/accessor/memberAttribute/extension/body/preamble)`, `#externalMacro`, and freestanding macro expansions (`#expect`, `#require`, `#Preview`, `#Predicate`, etc.)
  - **Typed Throws**: `throws(ErrorType)`, `do throws(ErrorType)`, `rethrows`
  - **Ownership, Noncopyable Containers & Accessors**: `~Copyable`, `~Escapable`, `~BitwiseCopyable`, `~Sendable`, `borrowing`, `consuming`, `consume`, `copy`, `discard self`, `unsafe`, `borrow` / `mutate` accessors, `yielding`, `RigidArray`, `InlineArray`, `UniqueArray`, `UniqueBox`, `Span`, `RawSpan`, `MutableSpan`, `MutableRawSpan`, `OutputSpan`, `OutputRawSpan`, `UTF8Span`
  - **Parameter Packs & InlineArray**: `each T`, `repeat each value`, `[N of Element]` (`InlineArray` sugar)
  - **Access Control, Availability & Modules**: `package` access level, Swift 6 access-level imports (`public import`, `package import`, `private import`, etc.), `Module::symbol` module selectors, `@available` / `@backDeployed` / `#available` platform & version highlighting (including `anyAppleOS` and `visionOS`), `@retroactive`
  - **Literals & Comments**: Native regex literals `/.../`, extended multiline regex literals `#/.../#`, raw strings `#"..."#` & interpolations `\#(...)`, multiline strings `"""..."""`, nested block comments `/* /* ... */ */`, and documentation comments `///` / `/** */`
- **Editor Integration**:
  - **Comments (`Comments.tmPreferences`)**: Toggle single-line (`Cmd+/`) and block (`Cmd+Opt+/`) comments
  - **Smart Indentation (`Indentation.tmPreferences`)**: Automatic indentation for `{}`, `[]`, `()`, and `switch` `case` / `default` blocks
  - **Xcode-style Symbol Navigation (`Symbol List*.tmPreferences`)**:
    - Jump to `struct`, `class`, `actor`, `enum`, `protocol`, `extension`, `func`, `macro`, `init`, `deinit`, and `subscript` via `Cmd+R` / `Cmd+Shift+R`
    - Renders `// MARK: - Section` as `— Section —` separator headers in `Cmd+R` (also supports `// MARK:`, `// TODO:`, and `// FIXME:`)

---

## Installation

### Via Package Control (Recommended)

1. Open Command Palette (`Cmd+Shift+P` on macOS, `Ctrl+Shift+P` on Windows/Linux).
2. Select **`Package Control: Install Package`**.
3. Search for **`Swift6`** and press Enter.

### Manual Installation (macOS)

```bash
chmod +x scripts/install_macos.sh
./scripts/install_macos.sh
```

---

## Syntax Tests & Verification

- **In Sublime Text 4**:
  1. Open [`tests/syntax_test_swift.swift`](tests/syntax_test_swift.swift) in Sublime Text 4.
  2. Open Command Palette (`Cmd+Shift+P`) and run **`Build With: Syntax Tests`** (verifies all scope assertions) and **`Build With: Syntax Tests - Regex Compatibility`** (verifies 100% native `sregex` engine compatibility).
- **From the Command Line**:
  ```bash
  ./scripts/verify.sh
  ```

## License

[MIT](LICENSE)
