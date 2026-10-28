# Swift6 (Sublime Text 插件) 维护指南

本文档记录 `Swift6`（仓库名：`sublime-swift`）插件的诞生背景、与同类插件的技术对比、当前功能状态、**Sublime Text 4 语法编写避坑经验**以及后续日常维护与版本发布流程。

---

## 一、项目背景与同类插件对比

### 1. 痛点与初衷
- macOS 上的 Sublime Text 4 是极佳的日常轻量级代码编辑器，但官方默认未内置 Swift 语法高亮。
- Package Control 上已有的 Swift 插件长期停滞，无法良好支持从 Swift 5.7 到 **Swift 6.x** 引入的大量现代语法（宏系统 `macro` / `@freestanding` / `@attached`、类型化抛出 `throws(Error)`、并发安全域隔离 `sending` / `#isolation` / `nonisolated(unsafe)` / `@isolated(any)`、不可拷贝类型与所有权 `~Copyable` / `~Escapable` / `borrowing` / `consuming` / `discard self`、参数包 `each` / `repeat`、原生正则字面量 `/.../` 与 `#/.../#`、`package` 访问级别、模块选择器 `Module::symbol`、`borrow`/`mutate` 访问器等）。

### 2. 与现有插件的深度架构对比（PR [#9632](https://github.com/sublimehq/package_control_channel/pull/9632) 背景）
在向 Package Control 提交收录时，我们对现有的两个同类仓库进行了源码级排查：

1. **`Decent Swift Syntax` (`colinta/decent-swift-syntax`)**：
   - 语法编写于 2015–2018 年（Swift 2/3 时代），缺乏现代 Scope Naming 规范与 Swift 5/6 语法支持，架构已过时。
2. **`Swift-Next` (`Swift-Next/Swift-Next`，含其后续社区 PR)**：
   - **重度耦合与非标准 Hack Scope**：`Swift-Next` 语法文件超过 2,300 行，为了在符号列表中拼凑类似 Xcode 的前缀，大量使用了违反 Sublime 官方规范的自定义 Scope（如代码注释中自述的 `keyword.symbol-list.swift`、`entity.name.x.extension.swift`、`meta.entity.name.let.swift`）。
   - **局部变量污染符号列表**：其 `Symbol List - Property.tmPreferences` 会将顶层脚本代码以及 `if` / `guard` / `for` / `while` 控制流块和闭包中的局部 `let` / `var` 变量一并塞入 `Cmd+R` 符号列表中。
   - **基于名称的 `grex` 巨型正则误伤普通代码**：其 `Swift - Standard Library.sublime-syntax` 将数千个标准库属性和方法压成单行巨型正则，导致用户代码中的任何 `.id`、`.name`、`.value`、`.count`、`.x`、`.y` 成员访问或 `get()`、`update()` 调用都会被无脑高亮为标准库常量/函数；同时将任何 3~4 个大写字母开头的类型（如 `URLSession`、`JSONDecoder`、`UUID`）误标为 `support.function.cocoa.swift`（C 函数）。
3. **`Swift6`（本项目）的设计定位**：
   - **纯粹、轻量、零侵入（Zero-bloat）**：单一 ~800 行的 `version: 2` `.sublime-syntax` 文件，严格遵循 Sublime Text 官方 [Scope Naming Guidelines](https://www.sublimetext.com/docs/scope_naming.html)，100% 兼容原生 `sregex` 极速引擎，不捆绑 Build System，不污染普通成员属性高亮与符号列表。

---

## 二、当前功能状态与文件架构

### 1. 目录结构

```text
/Users/guokai/dev/sublime-swift/
├── .github/
│   └── workflows/
│       └── syntax-tests.yml           # GitHub Actions CI：自动在 ST4 stable/latest 运行语法测试
├── Swift.sublime-syntax               # 核心：ST4 (version: 2) Swift 6 语法高亮状态机
├── Comments.tmPreferences             # 注释配置：支持 Cmd+/ 行注释与 Cmd+Opt+/ 块注释
├── Indentation.tmPreferences          # 缩进配置：支持 {}、[]、() 及 switch case/default 自动缩进
├── Symbol List.tmPreferences          # 符号索引：支持 Cmd+R / Cmd+Shift+R 跳转类型、函数、macro 等
├── Symbol List - Marks.tmPreferences  # MARK 导航：在 Cmd+R 中将 // MARK: - xxx 转换为分隔标题
├── tests/
│   └── syntax_test_swift.swift        # 官方格式的自动化语法高亮 Scope 断言测试套件（113 项断言）
├── scripts/
│   └── install_macos.sh               # 本机 macOS Sublime Text 软链接安装脚本
├── doc/
│   └── MAINTENANCE.md                 # 本维护文档（已通过 .gitattributes 从发布包排除）
├── .gitattributes                     # 控制 git archive 打包时剔除 .github/、tests/、scripts/、doc/ 等
├── .gitignore                         # 忽略缓存文件与构建产物
├── LICENSE                            # MIT 开源协议
└── README.md                          # 插件英文主页说明文档（Package Control 页面直接渲染此文件）
```

> **打包说明**：通过 [`.gitattributes`](../.gitattributes) 的 `export-ignore` 配置，当 GitHub 为版本 Tag 生成发布压缩包时，`.github/`、`tests/`、`scripts/`、`doc/`、`.gitignore`、`.gitattributes` 会被自动剔除。最终用户通过 Package Control 下载到的 `.sublime-package` 仅包含根目录下的 7 个核心文件。

---

### 2. 已支持的语言特性清单（截至 v1.0.4）

| 模块 | 已支持的具体语法 | 核心 Scope 命名 |
| :--- | :--- | :--- |
| **并发与隔离** | `async`, `reasync`, `await`, `actor`, `distributed actor`, `sending`, `isolated`, `nonisolated`, `nonisolated(unsafe)`, `nonisolated(nonsending)`, `#isolation`, `@isolated(any)`, `@MainActor`, `@Sendable`, `Sendable`, `SendableMetatype` | `storage.modifier.async.swift`, `storage.modifier.concurrency.swift`, `storage.type.actor.swift`, `keyword.control.flow.await.swift`, `variable.language.isolation.swift` |
| **宏系统 (Macros)** | `macro` 声明、`@freestanding(...)`、`@attached(...)`（支持嵌套括号参数如 `names: named(init)`）、`#externalMacro`、编译期宏展开（`#expect`, `#require`, `#Preview`, `#Predicate` 及带模块前缀的 `#Module.macro(...)`） | `storage.type.macro.swift`, `entity.name.function.macro.swift`, `variable.annotation.macro.swift`, `support.function.macro.swift` |
| **错误处理** | Swift 6 类型化抛出 `throws(ErrorType)`、普通 `throws` / `rethrows`、`do` / `try` / `try?` / `try!` / `catch` / `throw` | `keyword.control.exception.throws.swift`, `meta.throws.typed.swift`, `keyword.control.exception.swift` |
| **所有权与访问器** | `~Copyable`, `~Escapable`, `~BitwiseCopyable`, `borrowing`, `consuming`, `inout`, `yielding`, `consume`, `copy`, `discard self`, `unsafe` 表达式运算符，以及 Swift 6.4 `borrow` / `mutate` 访问器 | `meta.generic-constraint.suppressed.swift`, `storage.modifier.ownership.swift`, `keyword.operator.word.ownership.swift`, `keyword.operator.word.unsafe.swift`, `keyword.other.accessor.swift` |
| **泛型与参数包** | `some Protocol`, `any Protocol`, 参数包 `each T` 与 `repeat each x`（已与 `repeat { ... } while` 循环和 `for each in ...` 区分） | `storage.modifier.type.swift`, `keyword.operator.pack.swift` |
| **访问控制与模块** | `open`, `public`, `package`, `internal`, `fileprivate`, `private`（含 `...(set)` 形式）、Swift 6 访问级别导入 `public/package/... import`，以及 Swift 6.4 模块选择器 `Module::symbol` | `storage.modifier.access-control.swift`, `keyword.control.import.swift`, `punctuation.accessor.module.swift` |
| **字面量与正则** | 二进制 `0b` / 八进制 `0o` / 十六进制 `0x` / 十进制浮点与整数、单行/多行字符串 `"""..."""`、原始字符串 `#"..."#` 及插值 `\#(...)`、单行正则 `/.../`、扩展多行正则 `#/.../#` | `constant.numeric.*.swift`, `string.quoted.*.swift`, `meta.interpolation.swift`, `string.regexp.*.swift` |
| **注释与导航标签** | 单行注释 `//`、文档注释 `///` 与 `/** ... */`、支持多层嵌套的块注释 `/* /* ... */ */`、Xcode 风格 `// MARK: -` / `TODO:` / `FIXME:` | `comment.*.swift`, `entity.name.section.mark.swift` |
| **标准库类型与函数** | 涵盖 Swift 6.0–6.4 新增的 `InlineArray`, `UniqueArray`, `UniqueBox`, `Span`, `RawSpan`, `MutableSpan`, `OutputSpan`, `Ref`, `MutableRef`, `Mutex`, `Atomic`, `Regex`, `Iterable`, `BorrowingIteratorProtocol`, `ObservationRegistrar`, `ContinuousClock`, `Duration`, `TaskGroup`, `Int128`, `UInt128` 等 | `support.type.swift`, `support.function.builtin.swift` |

---

## 三、Sublime Text 4 语法编写四大实战避坑经验

在开发与 CI 验证过程中，我们总结了编写高质量 `.sublime-syntax` 的四条核心准则（后续修改语法时务必遵守）：

### 1. 严禁使用后行断言（`(?<=...)` 或 `(?<!...)`）
- **原因**：Sublime Text 4 拥有极其快速的原生正则引擎 `sregex`，但 **`sregex` 不支持任何正向或负向后行断言**。一旦语法文件中某条规则出现 `(?<=` 或 `(?<!`，Sublime Text 会被迫将该规则回退到较慢的旧版 Oniguruma 引擎（这也是 Package Control 官方审核员重点检查的性能指标）。
- **替代方案**：用前置消费规则或正向先行断言 `(?=...)` / `(?!...)` 替代后行断言。例如：
  - 在扩展正则 `#/.../#` 中，先匹配 `- match: '\\.'` 消费转义字符，下一条规则直接写 `- match: '#[^\r\n]*'` 即可安全匹配未转义的 `#` 注释，无需 `(?<!\\)#`。
  - 在单行正则 `/.../` 中，用 `((?:[^/\r\n\\\s]|\\.)(?:(?:[^/\r\n\\]|\\.)*(?:[^/\r\n\\\s]|\\.))?)` 约束首尾字符非空白，无需在末尾使用 `(?<!\s)`。
- **自检命令**：在 Sublime Text 中按 `` Ctrl+` `` 打开控制台，运行：
  ```python
  import sublime_api; sublime_api.incompatible_syntax_patterns("Packages/Swift/Swift.sublime-syntax")
  ```
  返回空列表 `[]` 即证明 100% 运行在 `sregex` 引擎上。

### 2. 上下文关键字（Contextual Keywords）必须防误伤
- **原因**：Swift 中大量现代关键字（`package`、`borrowing`、`consuming`、`sending`、`isolated`、`distributed`、`some`、`any`、`each`、`consume`、`copy`、`unsafe`、`borrow`、`mutate`）并非全局保留字，它们经常在普通代码中被用作变量名、参数名或成员属性名（如 `let package = 1`、`for each in items`、`worker.sending`、`worker.borrowing()`）。
- **防误伤写法**：
  1. 在 `declarations` 匹配修饰符之前，先匹配点号成员访问 `(\.)([a-z_]{{ident_char}}*)` 和反引号标识符 `` `[^`\r\n]+` ``，避免 `worker.sending` 或 `worker.borrowing()` 触发后续关键字规则。
  2. 为所有上下文修饰符加上严格的正向/负向先行断言，例如：
     - `each`：`\b(each)\b(?=\s+{{ident}})(?!\s*(?:[:=]|\b(?:in|as|is)\b))`（匹配 `each T`，但排除 `for each in list` 和 `if each is Int`）。
     - `package`：仅在后面紧跟声明关键字（`struct`/`class`/`func`/`import`/`var`/`let` 等或修饰符链）时才高亮为访问控制修饰符，从而放行 `let package = 1`。

### 3. 括号上下文（`push`）必须处理内部嵌套括号 `\(`
- **案例**：在解析宏属性 `@attached(member, names: named(init), arbitrary)` 时，如果 `@attached(` 推入的上下文只定义了遇到 `\)` 就 `pop: true`，那么内部 `named(init)` 的右括号 `)` 会把外层 `@attached(` 的上下文提前弹出，导致后面的 `, arbitrary)` 丢失高亮（此问题由 GitHub Actions CI 精准捕获）。
- **准则**：凡是以 `\(` 开始并依靠 `\)` 弹出的上下文（如 `macro-attribute-args`、`interpolation-body`），内部**必须**包含一条遇到 `\(` 递归 `push` 自身或嵌套括号上下文的规则，确保括号层级成对抵消。

### 4. `.sublime-syntax` 不支持跨 `push` 引用父级捕获组 `\1`
- 区别于旧版 TextMate `.tmLanguage` 的 `begin`/`end` 规则，Sublime Text 的 `push` 子上下文中写的正则与父级 `match` 是独立编译的（除非使用特殊的 `embed`/`escape` 机制）。因此对于 `#"..."#`、`##"..."##` 等可变数量 `#` 的原始字符串，采用显式分支上下文最为直观可靠。

---

## 四、本地开发与自动化测试

### 1. 本地生效方式（软链接 vs Package Control）
- **本地开发模式**：运行 `./scripts/install_macos.sh` 会在 `~/Library/Application Support/Sublime Text/Packages/Swift` 创建指向本仓库的软链接。修改仓库中的文件保存后，Sublime Text 会**实时热重载**。
- **切换到 Package Control 正式版**：当官方合并收录 PR 后，若希望改用 Package Control 托管的 `Swift6`，请先删除本地软链接（避免两份同名语法冲突）：
  ```bash
  rm "$HOME/Library/Application Support/Sublime Text/Packages/Swift"
  ```
  随后在 Sublime Text 中通过 `Cmd+Shift+P` -> `Package Control: Install Package` -> 安装 `Swift6`。

### 2. 本地测试与 GitHub Actions CI
- **本地运行语法测试**：在 Sublime Text 中打开 [`tests/syntax_test_swift.swift`](../tests/syntax_test_swift.swift)，按 `Cmd+Shift+P` 选择 **`Build With: Syntax Tests`**。
- **GitHub Actions 自动测试**：仓库已配置 [`.github/workflows/syntax-tests.yml`](../.github/workflows/syntax-tests.yml)，使用官方 `SublimeText/syntax-test-action@v2`。每次 `git push` 或提 PR 时，GitHub 会自动在 Ubuntu 环境拉起 Sublime Text 4 的 `stable` 和 `latest` 两个版本执行全量断言测试。
- **查看光标处的 Scope**：在 Sublime Text 中按 **`Ctrl+Opt+Cmd+P`**（macOS）即可查看当前光标处的完整 Scope 链。

---

## 五、版本发布与 Git 维护流程

本项目在 Package Control Channel (`sublimehq/package_control_channel`) 的 `repository/s.json` 中注册信息如下：

```json
{
	"name": "Swift6",
	"details": "https://github.com/hanguokai/sublime-swift",
	"labels": ["language syntax", "swift"],
	"releases": [
		{
			"sublime_text": ">=4075",
			"tags": true
		}
	]
}
```

### 日常发版标准步骤
由于配置了 `"tags": true`，后续升级无需再向官方 Channel 提 PR：

1. **修改代码并确认本地语法测试通过**。
2. **提交代码并打上新的 SemVer Tag**：
   > **注意**：Package Control 的检查机器人会检查最新 Tag 是否落后于 `main` 分支顶端（避免出现 `Latest version is X commits behind tip of main`）。因此每次完成一轮修改（哪怕只改了 README 或文档），如果要发版，都请把新 Tag 打在最新的 Commit 上。
   ```bash
   git add .
   git commit -m "Describe your changes..."
   git tag -a 1.0.5 -m "Release 1.0.5"
   git push origin main --tags
   ```
3. **验证打包内容（可选）**：
   ```bash
   git archive --format=tar HEAD | tar -t
   ```
