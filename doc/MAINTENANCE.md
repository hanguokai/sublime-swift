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
│       └── syntax-tests.yml           # GitHub Actions CI：执行 ./scripts/verify.sh + ST4 stable/latest 官方语法测试
├── Swift.sublime-syntax               # 核心：ST4 (version: 2) Swift 6 语法高亮状态机
├── Comments.tmPreferences             # 注释配置：支持 Cmd+/ 行注释与 Cmd+Opt+/ 块注释
├── Indentation.tmPreferences          # 缩进配置：支持 {}、[]、() 及 switch case/default 自动缩进
├── Symbol List.tmPreferences          # 符号索引：支持 Cmd+R / Cmd+Shift+R 跳转类型、函数、macro 等
├── Symbol List - Marks.tmPreferences  # MARK 导航：在 Cmd+R 中将 // MARK: - xxx 转换为分隔标题
├── tests/
│   └── syntax_test_swift.swift        # 官方格式的自动化语法高亮 Scope 断言测试套件（覆盖 100% 语法文件中定义的 166 个 Scope、共 3,500+ 列断言）
├── scripts/
│   ├── install_macos.sh               # 本机 macOS Sublime Text 软链接安装脚本
│   ├── sync_swift_spec.sh             # 从 swiftlang 官方仓库同步最新语法规范与词法表至 doc/spec/
│   └── verify.sh                      # 本地确定性全量验证脚本（sregex 检查 + 官方规范对齐审计 + 100% Scope 覆盖率 + 状态机全量断言模拟）
├── doc/
│   ├── MAINTENANCE.md                 # 本维护文档（已通过 .gitattributes 从发布包排除）
│   └── spec/                          # 官方 Swift 语言参考手册、EBNF 语法汇总、编译器词法表与 CHANGELOG 本地镜像
│       ├── SummaryOfTheGrammar.md     # 从 8 章 ReferenceManual 自动提取生成的完整官方 EBNF 语法规范
│       ├── LexicalStructure.md        # 官方词法结构规范（标识符、字面量、运算符、转义）
│       ├── Types.md                   # 官方类型语法规范
│       ├── Expressions.md             # 官方表达式语法规范
│       ├── Statements.md              # 官方语句与编译控制语法规范
│       ├── Declarations.md            # 官方声明与修饰符语法规范
│       ├── Attributes.md              # 官方特性 (@available, @attached, @freestanding 等) 规范
│       ├── Patterns.md                # 官方模式匹配语法规范
│       ├── GenericParametersAndArguments.md # 官方泛型参数与 ~Copyable/~Escapable/~Sendable 规范
│       ├── RevisionHistory.md         # TSPL 官方文档修订历史
│       ├── KeywordSpec.swift          # swift-syntax 编译器全量关键字词法定义表
│       ├── TokenSpec.swift            # swift-syntax 编译器全量 Token 与 #pound 关键字定义表
│       ├── AttributeNodes.swift       # swift-syntax 编译器内置特性节点表
│       └── CHANGELOG.md               # apple/swift 官方编译器演进日志（涵盖至 Swift 6.3 / 6.4 / Next）
├── .gitattributes                     # 控制 git archive 打包时剔除 .github/、tests/、scripts/、doc/ 等
├── .gitignore                         # 忽略缓存文件与构建产物
├── LICENSE                            # MIT 开源协议
└── README.md                          # 插件英文主页说明文档（Package Control 页面直接渲染此文件）
```

> **打包说明**：通过 [`.gitattributes`](../.gitattributes) 的 `export-ignore` 配置，当 GitHub 为版本 Tag 生成发布压缩包时，`.github/`、`tests/`、`scripts/`、`doc/`（含 `doc/spec/`）、`.gitignore`、`.gitattributes` 会被自动剔除。最终用户通过 Package Control 下载到的 `.sublime-package` 仅包含根目录下的 7 个核心文件。

---

### 2. 已支持的语言特性清单（涵盖至 Swift 6.4）

| 模块 | 已支持的具体语法 | 核心 Scope 命名 |
| :--- | :--- | :--- |
| **并发与隔离** | `async`, `reasync`, `await`, `actor`, `distributed actor`, `sending`, `isolated`, `isolated deinit` (SE-0371), `nonisolated`, `nonisolated(unsafe)`, `nonisolated(nonsending)` (SE-0461), `#isolation`, `@isolated(any)`, `@MainActor`, `@Sendable`, `~Sendable` (SE-0518), `Sendable`, `SendableMetatype`, `withTaskCancellationShield` (SE-0504), `withTaskPriorityEscalationHandler` (SE-0462), `withTaskExecutorPreference`, `withDeadline` | `storage.modifier.async.swift`, `storage.modifier.concurrency.swift`, `storage.type.actor.swift`, `keyword.control.flow.await.swift`, `variable.language.isolation.swift`, `support.function.builtin.swift` |
| **宏系统 (Macros)** | `macro` 声明、`@freestanding(expression/declaration)`、`@attached(member/peer/accessor/memberAttribute/extension/body/preamble)`（支持嵌套括号参数如 `names: named(init)`）、`#externalMacro`、编译期宏展开（`#expect`, `#require`, `#Preview`, `#Predicate` 及带模块前缀的 `#Module.macro(...)`） | `storage.type.macro.swift`, `entity.name.function.macro.swift`, `variable.annotation.macro.swift`, `support.function.macro.swift` |
| **错误处理** | Swift 6 类型化抛出 `throws(ErrorType)`、`do throws(ErrorType) { ... } catch`、普通 `throws` / `rethrows`、`do` / `try` / `try?` / `try!` / `catch` / `throw` | `keyword.control.exception.throws.swift`, `meta.throws.typed.swift`, `keyword.control.exception.swift` |
| **所有权与抑制约束** | `~Copyable`, `~Escapable`, `~BitwiseCopyable`, `~Sendable` (Swift 6.4 SE-0518), `borrowing`, `consuming`, `inout`, `yielding`, `consume`, `copy`, `discard self`, `unsafe` 表达式运算符，以及 Swift 6.4 `borrow` / `mutate` 访问器 (SE-0474) | `meta.generic-constraint.suppressed.swift`, `keyword.operator.tilde.suppressed.swift`, `support.type.protocol.suppressed.swift`, `storage.modifier.ownership.swift`, `keyword.operator.word.ownership.swift`, `keyword.operator.word.unsafe.swift`, `keyword.other.accessor.swift` |
| **泛型、元类型与运算符** | `some Protocol`, `any Protocol`, `<let N: Int>` 整数泛型参数 (SE-0452), `[N of Element]` (`InlineArray` 类型糖), 参数包 `each T` 与 `repeat each x`, 显式元类型与自身引用 `.Type` / `.Protocol` / `.self`, 以及 `precedencegroup` 属性（`higherThan`, `lowerThan`, `associativity: left/right/none`, `assignment`） | `storage.modifier.type.swift`, `keyword.operator.word.swift`, `keyword.operator.pack.swift`, `variable.language.swift`, `keyword.other.operator.precedence.swift`, `constant.language.precedence.swift` |
| **访问控制、可用性与模块** | `open`, `public`, `package`, `internal`, `fileprivate`, `private`（含 `...(set)` 形式）、Swift 6 访问级别导入 `public/package/... import`、模块选择器 `Module::symbol` (SE-0491)、`@diagnose` 自定义诊断特性 (SE-0522)，以及 `#if` / `#available` / `#unavailable` / `@available` / `@backDeployed` 平台与版本参数高亮（含 Swift 6.4 `anyAppleOS`、`visionOS`、`introduced`、`deprecated`、`obsoleted`、`unavailable`、`noasync`、`before` 等） | `storage.modifier.access-control.swift`, `keyword.control.import.swift`, `punctuation.accessor.module.swift`, `meta.availability.swift`, `support.constant.directive.swift`, `support.constant.attribute.availability.swift` |
| **字面量、原始标识符与正则** | 二进制 `0b` / 八进制 `0o` / 十六进制 `0x` / 十进制浮点与整数、单行/多行字符串 `"""..."""`（支持多行字符串行尾反斜杠续行后跟空白符 `\[ \t]*\n`）、原始字符串 `#"..."#` 及插值 `\#(...)`、原始标识符 `` `raw name` `` / `` `$raw property` `` (SE-0451 / Swift 6.4 TSPL)、单行正则 `/.../`、扩展多行正则 `#/.../#` | `constant.numeric.*.swift`, `string.quoted.*.swift`, `meta.interpolation.swift`, `string.regexp.*.swift`, `variable.function.swift`, `variable.other.projected.swift` |
| **注释与导航标签** | 单行注释 `//`、文档注释 `///` 与 `/** ... */`、支持多层嵌套的块注释 `/* /* ... */ */`、Xcode 风格 `// MARK: -` / `TODO:` / `FIXME:` | `comment.*.swift`, `entity.name.section.mark.swift` |
| **标准库类型与函数** | 涵盖 Swift 6.0–6.4 新增的 `RigidArray`, `InlineArray`, `UniqueArray`, `UniqueBox`, `Span`, `RawSpan`, `MutableSpan`, `MutableRawSpan`, `OutputSpan`, `OutputRawSpan`, `UTF8Span`, `RangeSet`, `DiscontiguousSlice`, `OpaquePointer`, `Ref`, `MutableRef`, `Mutex`, `Atomic`, `AtomicLazyReference`, `Regex`, `Iterable`, `BorrowingIteratorProtocol`, `ObservationRegistrar`, `EncodingError`, `DecodingError`, `CancellationError`, `Int128`, `UInt128`, `withUnsafeTemporaryAllocation` 等 | `support.type.swift`, `support.function.builtin.swift` |

---

## 三、Sublime Text 4 语法编写五大实战避坑经验

在开发与 CI 验证过程中，我们总结了编写高质量 `.sublime-syntax` 的五条核心准则（后续修改语法时务必遵守）：

### 1. 严禁使用后行断言（`(?<=...)` 或 `(?<!...)`）
- **原因**：Sublime Text 4 拥有极其快速的原生正则引擎 `sregex`，但 **`sregex` 不支持任何正向或负向后行断言**。一旦语法文件中某条规则出现 `(?<=` 或 `(?<!`，Sublime Text 会被迫将该规则回退到较慢的旧版 Oniguruma 引擎（这也是 Package Control 官方审核员重点检查的性能指标）。
- **替代方案**：用前置消费规则或正向先行断言 `(?=...)` / `(?!...)` 替代后行断言。例如：
  - 在扩展正则 `#/.../#` 中，先匹配 `- match: '\\.'` 消费转义字符，下一条规则直接写 `- match: '#[^\r\n]*'` 即可安全匹配未转义的 `#` 注释，无需 `(?<!\\)#`。
  - 在单行正则 `/.../` 中，用 `((?:[^/\r\n\\\s]|\\.)(?:(?:[^/\r\n\\]|\\.)*(?:[^/\r\n\\\s]|\\.))?)` 约束首尾字符非空白，无需在末尾使用 `(?<!\s)`。
- **自检命令**：
  1. 命令行运行 `./scripts/verify.sh`（会自动扫描所有展开后的正则是否包含 `(?<=`、`(?<!` 或 `\1`..`\9` 反向引用）；
  2. 在 Sublime Text 中打开 [`Swift.sublime-syntax`](../Swift.sublime-syntax) 或 [`tests/syntax_test_swift.swift`](../tests/syntax_test_swift.swift)，按 `Cmd+Shift+P` 选择 **`Build With: Syntax Tests - Regex Compatibility`**，输出 `Success: all patterns ... are compatible with the new regex engine` 即表示无任何规则回退；
  3. 或在 Sublime Text 控制台（`` Ctrl+` ``）中运行：
     ```python
     import sublime_api; sublime_api.incompatible_syntax_patterns("Packages/Swift/Swift.sublime-syntax")
     ```
     返回空列表 `[]` 即证明 100% 运行在 `sregex` 引擎上。

### 2. 上下文关键字（Contextual Keywords）必须防误伤
- **原因**：Swift 中大量现代关键字（`package`、`borrowing`、`consuming`、`sending`、`isolated`、`distributed`、`some`、`any`、`each`、`consume`、`copy`、`unsafe`、`borrow`、`mutate`）并非全局保留字，它们经常在普通代码中被用作变量名、参数名或成员属性名（如 `let package = 1`、`for each in items`、`worker.sending`、`worker.borrowing()`）。
- **防误伤写法**：
  1. 在 `declarations` 匹配修饰符之前，先匹配点号成员访问 `(\.)([[:lower:]_]{{ident_char}}*)` 和反引号标识符 `` `[^`\\\r\n]+` ``，避免 `worker.sending` 或 `worker.borrowing()` 触发后续关键字规则。
  2. 为所有上下文修饰符加上严格的正向/负向先行断言，例如：
     - `each`：`\b(each)\b(?=\s+{{ident}})(?!\s*(?:[:=]|\b(?:in|as|is|where|else|catch)\b))`（匹配 `each T`，但排除 `for each in list`、`if each is Int`、`guard let borrowing else` 等）。
     - `package`：仅在后面紧跟声明关键字（`struct`/`class`/`func`/`import`/`var`/`let`/`deinit` 等或修饰符链）时才高亮为访问控制修饰符，从而放行 `let package = 1`。

### 3. 括号上下文（`push`）必须处理内部嵌套括号 `\(`
- **案例**：在解析宏属性 `@attached(member, names: named(init), arbitrary)` 或 `@available(...)` 时，如果推入的上下文只定义了遇到 `\)` 就 `pop: true`，那么内部 `named(init)` 的右括号 `)` 会把外层上下文提前弹出，导致后面的 `, arbitrary)` 丢失高亮。
- **准则**：凡是以 `\(` 开始并依靠 `\)` 弹出的上下文（如 `availability-args`、`macro-attribute-args`、`interpolation-body`），内部**必须**包含一条遇到 `\(` 递归 `push` 自身或嵌套括号上下文的规则，确保括号层级成对抵消。

### 4. 原始字符串使用显式分支，不使用 `\1` 反向引用
- 为了保证 100% 兼容 `sregex` DFA 引擎（`sregex` 不支持反向引用 `\1`），`#"..."#`、`##"..."##`、`###+"..."###+` 均按 `#` 的数量写成显式分支，并通过 `./scripts/verify.sh` 强制拦截任何 `\1`..`\9` 反向引用。

### 5. 负向先行断言不能直接跟在变长捕获后面；关键字标签只用“前置分隔符”识别
- **案例（V2 审查修复过程中出现过的回归）**：曾给 `\b(enum)\s+({{ident}})(?!\s*:\s*[^{};\r\n]*\))` 这类规则加负向先行断言，想排除参数标签。结果正则引擎通过**回溯缩短 `{{ident}}`** 来让断言成立，`enum Kind: String // (a, b)` 被高亮成类型名 `Kin`，并污染了符号索引。
- **准则**：
  1. 不要在 `({{ident}})` 这类变长捕获后面紧跟负向断言，除非断言本身以 `\b` 或必然失败的字符开头。
  2. 关键字作为参数/实参标签（`f(default: 1)`、`dict[k, default: 0]`、`func f(in ctx: C, class k: Int)`）统一由 `declarations` 顶部的一条规则处理：消费前置的 `(` / `[` / `,`，再匹配 `{{label_keyword}}`。**不要**给 `case`、`where`、`default`、`each` 等关键字加“同一行后面有 `)`”之类的启发式断言，否则 `case foo: f()`、`default: print(x)`、`<each T: P>(...)`、`where T == (A, B)` 都会丢失高亮。
  3. 已知限制：多行参数列表中，位于行首的 `class k: Int` / `for item: T` 这类标签无法与声明或语句区分（`in` 和 `default` 除外，因为 `in x:` / `default x:` 不可能是合法语句）。

---

## 四、以官方规范与确定性测试为准绳的维护工作流（Spec-Driven Workflow）

> **致后续维护者与 AI 编程助手**：切勿仅凭大模型记忆（LLM 参数知识）猜测或拼凑 Swift 语法规则。每次更新或排查语法高亮时，**必须**严格遵循以下三步确定性工程流程：

### 1. 同步并查阅本地官方语言规范（`doc/spec/`）
当 Swift 发布新版本（如 Swift 6.4、6.5）时，首先执行同步脚本拉取苹果官方仓库的最新规范：
```bash
./scripts/sync_swift_spec.sh
```
该脚本会从 `swiftlang/swift-book`、`swiftlang/swift-syntax` 和 `swiftlang/swift` 自动同步并生成：
- **`doc/spec/SummaryOfTheGrammar.md`**：从 `ReferenceManual` 八大章节自动提取生成的完整官方 EBNF 语法产生式汇总。
- **`doc/spec/LexicalStructure.md` / `Declarations.md` / `Attributes.md` / `Types.md` / `Expressions.md` / `Statements.md` / `Patterns.md` / `GenericParametersAndArguments.md`**：官方语言参考手册全文。
- **`doc/spec/KeywordSpec.swift` & `TokenSpec.swift` & `AttributeNodes.swift`**：Swift 编译器 `swift-syntax` 的权威词法关键字与 Token 定义表。
- **`doc/spec/CHANGELOG.md`**：Swift 官方编译器完整演进日志（记录了每个 SE 提案的具体语法示例）。

### 2. 运行本地确定性全量验证脚本（`./scripts/verify.sh`）
任何对 `Swift.sublime-syntax` 或 `tests/syntax_test_swift.swift` 的修改，必须在命令行执行：
```bash
./scripts/verify.sh
```
`verify.sh` 会在 1 秒内完成四项硬性验证（全部 0 错误才算通过）：
1. **语法结构与 `sregex` 兼容性检查**：验证所有变量展开、上下文引用完整性，并确保 0 个后行断言（`(?<=` / `(?<!`）和 0 个反向引用（`\1`..`\9`）。
2. **官方规范对齐审计**：自动解析 `doc/spec/SummaryOfTheGrammar.md`（提取全部 135 个 EBNF 词法终结符 `` **`...`** ``）、`doc/spec/KeywordSpec.swift`（所有 `isLexerClassified: true` 关键字）、`doc/spec/TokenSpec.swift`（所有 `#pound` 关键字）以及 Swift 5.9–6.4 新增特性清单，校验它们在 `Swift.sublime-syntax` 与 `tests/syntax_test_swift.swift` 中无一遗漏。
3. **100% Scope 覆盖率检查**：提取 `Swift.sublime-syntax` 中定义的全部 166 个 Scope，强制要求每一个 Scope 在 `tests/syntax_test_swift.swift` 中至少有一条断言覆盖。
4. **`.sublime-syntax` 状态机全量断言模拟**：在本地精确模拟 Sublime Text 的 `push`/`pop`/`set`/`include`/`meta_scope`/`meta_content_scope`/`clear_scopes` 状态机，对 `tests/syntax_test_swift.swift` 中的 3,500+ 个列级正向/负向 Scope 断言逐一校验。

### 3. 本地安装与 GitHub Actions CI
- **本地开发模式**：运行 `./scripts/install_macos.sh` 会在 `~/Library/Application Support/Sublime Text/Packages/Swift` 创建指向本仓库的软链接。修改仓库中的文件保存后，Sublime Text 会**实时热重载**。
- **切换到 Package Control 正式版**：若希望改用 Package Control 托管的 `Swift6`，请先删除本地软链接（避免两份同名语法冲突）：
  ```bash
  rm "$HOME/Library/Application Support/Sublime Text/Packages/Swift"
  ```
  随后在 Sublime Text 中通过 `Cmd+Shift+P` -> `Package Control: Install Package` -> 安装 `Swift6`。
- **Sublime Text 内置语法测试**：在 Sublime Text 中打开 [`tests/syntax_test_swift.swift`](../tests/syntax_test_swift.swift)，按 `Cmd+Shift+P` 依次运行：
  - **`Build With: Syntax Tests`**（执行全量 Scope 断言测试）
  - **`Build With: Syntax Tests - Regex Compatibility`**（校验所有正则 100% 兼容原生 `sregex` 引擎）
- **GitHub Actions 自动测试**：仓库已配置 [`.github/workflows/syntax-tests.yml`](../.github/workflows/syntax-tests.yml)，每次 `git push` 或提 PR 时会自动运行 `./scripts/verify.sh` 以及官方 `SublimeText/syntax-test-action@v2`（同时在 ST4 `stable` 和 `latest` 上执行验证）。
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
