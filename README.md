# Swift for Sublime Text

**Swift** syntax highlighting and editor integration for **Sublime Text** (Sublime Text 3 `>=3092` and Sublime Text 4).

Built from the ground up against the official Swift language grammar and lexical specification, this package targets modern Swift (**Swift 5.x – 6.4**), follows Sublime Text's official [Scope Naming Guidelines](https://www.sublimetext.com/docs/scope_naming.html), and runs 100% natively on Sublime Text 4's high-performance `sregex` engine.

---

## Features

- **Syntax Highlighting**: Comprehensive, specification-aligned highlighting for **Swift 5.x – 6.4**—covering structured concurrency (`async`/`await`, `actor`, `sending`, `nonisolated`, `#isolation`), macros (`macro`, `@freestanding`, `@attached`, `#expect`, `#Preview`), typed `throws`, ownership and noncopyable types (`~Copyable`, `~Escapable`, `~Sendable`, `borrowing`, `consuming`, `borrow`/`mutate`), parameter packs (`each`/`repeat`), inline arrays (`[N of Type]`), regex literals (`/.../`, `#/.../#`), raw strings (`#"..."#`), and documentation comments (`///`, `/** ... */`).
- **Comment Toggling**: Single-line (`//`) and block (`/* ... */`) comment toggling via `Cmd+/` / `Ctrl+/` and `Cmd+Opt+/` / `Ctrl+Shift+/`.
- **Smart Indentation**: Automatic indentation rules for braces, brackets, parentheses, and `switch` `case` / `default` blocks.
- **Symbol Navigation**: Goto Symbol (`Cmd+R` / `Ctrl+R`) and Goto Symbol in Project (`Cmd+Shift+R` / `Ctrl+Shift+R`) for types, protocols, extensions, functions, macros, initializers, subscripts, and Xcode-style `// MARK:`, `// TODO:`, and `// FIXME:` section headers.

---

## Installation

1. Open the Command Palette (`Cmd+Shift+P` on macOS, `Ctrl+Shift+P` on Windows/Linux).
2. Select **`Package Control: Install Package`**.
3. Search for **`Swift`** and press Enter.

---

## Local Development & Testing

1. **Clone and link the repository into Sublime Text (macOS)**:
   ```bash
   git clone https://github.com/hanguokai/sublime-swift.git
   cd sublime-swift
   ./scripts/install_macos.sh
   ```
   *(If `Swift` is already installed via Package Control, linking `Packages/Swift` overrides the packaged version during development.)*

2. **Run the command-line verification suite**:
   ```bash
   ./scripts/verify.sh
   ```

3. **Run Sublime Text's built-in syntax tests**:
   Open the target file via the `Packages/Swift` symlink path (required by Sublime Text's test runner when the repository folder is not named `Swift`) and run the corresponding build target from the Command Palette (`Cmd+Shift+P`):
   - **Scope Assertions (`Build With: Syntax Tests`)** — open `tests/syntax_test_swift.swift` to verify all scope assertions in the test suite:
     ```bash
     subl "$HOME/Library/Application Support/Sublime Text/Packages/Swift/tests/syntax_test_swift.swift"
     ```
   - **Regex Engine Compatibility (`Build With: Syntax Tests - Regex Compatibility`)** — open `Swift.sublime-syntax` to verify 100% native `sregex` engine compatibility:
     ```bash
     subl "$HOME/Library/Application Support/Sublime Text/Packages/Swift/Swift.sublime-syntax"
     ```

---

## History & Legacy Releases

This package succeeds the original [`Swift`](https://github.com/quiqueg/Swift-Sublime-Package) package created by [@quiqueg](https://github.com/quiqueg).

- **Sublime Text 3 (`>=3092`) & Sublime Text 4**: Track the `main` branch (`1.x` releases).
- **Sublime Text 2 (`<3092`)**: The original 2014–2016 `.tmLanguage` snapshot is preserved on the [`st2` branch](https://github.com/hanguokai/sublime-swift/tree/st2) under tag [`st2-0.0.9`](https://github.com/hanguokai/sublime-swift/releases/tag/st2-0.0.9).

## License

[MIT](LICENSE)
