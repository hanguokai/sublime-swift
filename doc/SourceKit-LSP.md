# Using SourceKit-LSP with Swift for Sublime Text

This guide explains how to pair the **`Swift`** syntax highlighting package with Sublime Text's [**`LSP`**](https://packagecontrol.io/packages/LSP) plugin and Apple's official [**`sourcekit-lsp`**](https://github.com/swiftlang/sourcekit-lsp) language server for **Semantic Highlighting**, **Code Completion**, **Hover Documentation**, and **Jump to Definition**.

---

## Syntax Highlighting vs. LSP: Do You Need It?

Before installing a language server, it helps to understand how **Syntax Highlighting** (provided by this **`Swift`** package) and **Language Server Protocol (LSP)** features work together, and when you actually need LSP.

### How They Complement Each Other

- **Layer 1 — Syntax Highlighting (`Swift` package)**: Runs directly inside Sublime Text. The moment you open any `.swift` file, it highlights keywords, concurrency modifiers (`async`, `actor`, `sending`, `nonisolated`), macros, ownership annotations (`borrowing`, `~Copyable`), attributes, strings, regex literals, comments, UpperCamelCase types, and `foo(...)` function calls. It requires **zero project configuration** and **zero background processes**.
- **Layer 2 — Compiler Intelligence (`LSP` + `sourcekit-lsp`)**: Runs Apple's Swift compiler service in the background to understand types, declarations, and relationships across all files in your project.

### What Enabling LSP Adds for Reading & Writing Code

**1. Interactive Code Reading & Navigation (Major Benefit)**

- **Type Inference & DocC Hover**: Swift relies heavily on type inference (`let result = try await service.fetch()`, closure shorthand `$0`). Hovering over any identifier displays its compiler-inferred type signature and rendered `///` DocC documentation comments.
- **Compiler-Accurate Jump to Definition & References**: Sublime Text's built-in symbol navigation (`Cmd+R` / `F12`) matches symbol names by text. `sourcekit-lsp` resolves overloaded functions, protocol requirements, extensions, and cross-module declarations to their exact target definition.
- **Context-Aware Auto-Completion**: Provides type-checked member completions, method signatures, and enum cases.

**2. Semantic Highlighting (Subtle Visual Refinement)**

Because the **`Swift`** package already highlights Swift 5.x–6.4 syntax comprehensively, turning on LSP semantic highlighting adds a **~10–15% visual refinement** for identifiers that only a compiler can tell apart:

- Distinguishing **instance properties** from **local variables** and **function parameters**—even when `self.` is omitted.
- Highlighting unparenthesized **trailing-closure method calls** (e.g., `numbers.filter { $0 > 0 }`) as methods rather than plain properties.
- Distinguishing **enum cases** (`.active`) and **standard library symbols**.

### Resource & Performance Trade-Offs

| Dimension | `Swift` Package Only | `Swift` + `LSP` (`sourcekit-lsp`) |
| :--- | :--- | :--- |
| **How It Works** | Built-in syntax highlighting inside Sublime Text | Background `sourcekit-lsp` + `SourceKitService` compiler processes |
| **Startup Speed** | **Instant** | Seconds (loads SDK modules & project build graph) |
| **Memory Usage** | **~0 MB** | **~150 MB** (single files), **300 MB – 1 GB+** (indexed projects) |
| **CPU & Battery Impact** | **None** | Active during file edits and background module indexing |

### Conclusion & Recommended Best Practice

- **Just reading code or editing quick files? You do NOT need LSP**: If you mainly use Sublime Text to browse `.swift` files, read code snippets, or edit scripts, the **`Swift`** syntax package alone is already sufficient—giving you comprehensive Swift 5.x–6.4 highlighting with instant startup and zero background overhead.
- **Using Sublime Text as a full Swift IDE? Enable LSP per project**: If you want compiler-driven auto-completion, inferred type hover, cross-file jump-to-definition, and semantic highlighting for a multi-file Swift project, install **`LSP`** and **`sourcekit-lsp`**.
- **Best Practice — Keep Disabled Globally, Enable Per Project**: Even after installing `LSP`, keep `sourcekit-lsp` **disabled globally** by default and enable it **only for specific projects** via the Command Palette (`LSP: Enable Language Server in Project`). This gives you the best of both worlds: zero overhead for casual file viewing, and full IDE power when working on a project.

---

## Installation & Setup

### Step 1: Verify `sourcekit-lsp` on Your System

[**`sourcekit-lsp`**](https://github.com/swiftlang/sourcekit-lsp) is bundled directly with Apple's official Swift toolchains. You do **not** need to build or download it separately:

- **macOS**: Included automatically with **Xcode** or the **Xcode Command Line Tools** (`xcode-select --install`).
- **Linux / Windows**: Included with the official [Swift.org toolchain](https://www.swift.org/install/) (ensure the toolchain's `usr/bin` directory is in your `$PATH`).

To verify that `sourcekit-lsp` is installed on macOS, run in Terminal:

```bash
xcrun --find sourcekit-lsp
swift --version
```

If it prints a path such as `/Library/Developer/CommandLineTools/usr/bin/sourcekit-lsp` or `/Applications/Xcode.app/.../usr/bin/sourcekit-lsp`, your system is ready.

### Step 2: Configure Sublime Text

Once the **`Swift`** package is installed, you can connect Sublime Text 4 to `sourcekit-lsp` using either **Option A** (with the `LSP-SourceKit` helper package) or **Option B** (using `LSP` directly without extra packages).

#### Option A: `Swift` + `LSP` + `LSP-SourceKit` (Standard Helper Package)

1. Open the Command Palette (`Cmd+Shift+P` on macOS, `Ctrl+Shift+P` on Linux/Windows) and select **`Package Control: Install Package`**.
2. Install [**`LSP`**](https://packagecontrol.io/packages/LSP) and [**`LSP-SourceKit`**](https://packagecontrol.io/packages/LSP-SourceKit) (alongside **`Swift`**).
3. Enable `sourcekit-lsp` for your project (or globally):

- **Per-Project (Recommended)**: Open your Swift project folder in Sublime Text, open the Command Palette (`Cmd+Shift+P`), run **`LSP: Enable Language Server in Project`**, and select **`LSP-SourceKit`**.
- **Globally (Always On)**: Open the Command Palette, run **`Preferences: LSP-SourceKit Settings`**, and set `"enabled": true`:

```json
{
    "enabled": true
}
```

#### Option B: `Swift` + `LSP` Only (Direct Configuration, No Extra Helper Package)

`LSP-SourceKit` is only a thin configuration wrapper. If you prefer not to install an extra package, you can configure `sourcekit-lsp` directly inside **`LSP`**:

1. Install [**`LSP`**](https://packagecontrol.io/packages/LSP) via Package Control.
2. Open the Command Palette (`Cmd+Shift+P`) and run **`Preferences: LSP Settings`**.
3. Add `"sourcekit-lsp"` under `"clients"` (on Linux, use `"command": ["sourcekit-lsp"]` instead of `["xcrun", "sourcekit-lsp"]`):

```json
{
    "clients": {
        "sourcekit-lsp": {
            "enabled": false,
            "command": ["xcrun", "sourcekit-lsp"],
            "selector": "source.swift"
        }
    }
}
```

Then enable it for your current project via **`LSP: Enable Language Server in Project`** → **`sourcekit-lsp`** (or set `"enabled": true` above to keep it always on).

### Step 3: Enable Semantic Highlighting & Verify

**1. Turn On Semantic Highlighting in `LSP`**

Sublime Text's `LSP` package disables semantic highlighting by default. To enable it, open **`Preferences: LSP Settings`** from the Command Palette and add:

```json
{
    "semantic_highlighting": true
}
```

**2. Color Scheme Compatibility**

- **Built-in Color Schemes** (*Mariana*, *Monokai*, *Breakers*, *Sixteen*): `LSP` automatically injects the required semantic token rule—no extra setup needed.
- **Custom / Third-Party Color Schemes**: If semantic tokens do not appear in your custom theme, open the Command Palette, run **`UI: Customize Color Scheme`**, and add this rule to the right-hand pane:

```json
{
    "rules": [
        {
            "scope": "meta.semantic-token",
            "background": "#00000101"
        }
    ]
}
```

> **Tip**: If you use a custom `.sourcekit-lsp/config.json` file, keep `"reportSyntacticHighlightInSemanticTokens"` at its default (`false`) so `sourcekit-lsp` only highlights semantic identifiers without overriding the **`Swift`** package's keyword colors and bold/italic font styles.

**3. Quick Verification Checklist**

Open any `.swift` file in an active project to confirm everything is working:

- **Status Bar**: Check the bottom-left status bar in Sublime Text—it should display **`LSP: SourceKit`** (Option A) or **`sourcekit-lsp`** (Option B).
- **Hover Popup**: Hover your mouse over any variable, function, or standard library type (such as `String` or `Task`) to see its inferred type signature and documentation popup.
- **Jump to Definition**: Right-click a symbol and select **`LSP: Goto Definition`** (or press `F12`) to jump directly to its declaration.

---

## Project Setup: Cross-File & Cross-Module Resolution

Unlike syntax highlighting—which only looks at the text of the current file—`sourcekit-lsp` runs the Swift compiler in the background. To resolve types across multiple `.swift` files, find third-party dependencies, or know which platform SDK (e.g., macOS vs. iOS `UIKit`) to target, `sourcekit-lsp` needs to understand your project's structure:

### 1. Standalone `.swift` Files or Plain Folders (No Project File)

- **What works**: Single-file type checking, semantic highlighting, hover documentation, and completions for declarations inside the same file and standard library modules (such as `Foundation`).
- **Limitation**: Without a project manifest, `sourcekit-lsp` does not know that `FileA.swift` and `FileB.swift` belong to the same module, so cross-file references will not resolve.

### 2. Swift Package Manager Projects (`Package.swift`) — Native Support

- `sourcekit-lsp` has built-in, first-class support for **SwiftPM** projects.
- Simply open the folder containing `Package.swift` in Sublime Text (**`File > Open Folder...`**).
- **Cross-Module Indexing**: On older toolchains (or if cross-module symbols have not been indexed yet), run `swift build` once in your project directory so `sourcekit-lsp` can read the module index store. In **Swift 6.0+**, you can also enable automatic background indexing by creating `~/.sourcekit-lsp/config.json` (or `.sourcekit-lsp/config.json` in your project root):

```json
{
    "backgroundIndexing": true
}
```

### 3. Xcode Projects (`.xcodeproj` / `.xcworkspace`)

- **Not natively supported**: Because `.xcodeproj` and `.xcworkspace` use Xcode's proprietary build system (which already provides its own full IDE features inside Xcode), `sourcekit-lsp` does not parse them out of the box.
- **Workaround (Optional)**: If you still wish to use `sourcekit-lsp` with an Xcode project in Sublime Text, you can bridge Xcode's build settings using a third-party Build Server Protocol (BSP) tool such as [**`xcode-build-server`**](https://github.com/SolaWing/xcode-build-server) or by organizing your code into local Swift packages (`Package.swift`).
