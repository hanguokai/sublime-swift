# Swift6 (Sublime Text 插件) 维护指南

本文档记录 `Swift6`（仓库名：`sublime-swift`）插件的诞生背景、架构设计、当前功能状态以及后续日常维护与版本发布流程。

---

## 一、项目背景与前因后果

1. **痛点**：
   - macOS 上的 Sublime Text 4 是极佳的日常轻量级代码编辑器，但官方默认未内置 Swift 语法高亮。
   - Package Control 上已有的 Swift 插件均已长期停止维护：其中较新的 [`Swift-Next`](https://github.com/Swift-Next/Swift-Next) 也已停更 2 年以上，语法支持仅停留在 **Swift 5.6**。
   - 从 Swift 5.7 到 **Swift 6.x**，Swift 引入了大量核心语法变革（如宏系统 `macro` / `@freestanding` / `@attached`、类型化抛出 `throws(Error)`、并发安全域隔离 `sending` / `#isolation` / `nonisolated(unsafe)` / `@isolated(any)`、不可拷贝类型与所有权 `~Copyable` / `~Escapable` / `borrowing` / `consuming` / `discard self`、变长泛型参数包 `each` / `repeat`、原生正则字面量 `/.../` 与 `#/.../#`、`package` 访问级别及带访问级别的 `import` 等），旧插件无法正确识别和高亮。
2. **解决方案**：
   - 从零构建一个精简、现代、无历史包袱的 Sublime Text 4 语法支持插件（注册名：**`Swift6`**）。
   - 采用 Sublime Text 4 原生的 **`version: 2` `.sublime-syntax` 状态机引擎** 与官方最新 [Scope Naming Guidelines](https://www.sublimetext.com/docs/scope_naming.html)，不捆绑任何第三方配色方案或冗余 Python 脚本，实现零性能开销、兼容所有主流主题的语法高亮与符号导航。

---

## 二、当前功能状态与文件架构

### 1. 目录结构

```text
/Users/guokai/dev/sublime-swift/
├── Swift.sublime-syntax               # 核心：ST4 (version: 2) Swift 6 语法高亮状态机
├── Comments.tmPreferences             # 注释配置：支持 Cmd+/ 行注释与 Cmd+Opt+/ 块注释
├── Indentation.tmPreferences          # 缩进配置：支持 {}、[]、() 及 switch case/default 自动缩进
├── Symbol List.tmPreferences          # 符号索引：支持 Cmd+R / Cmd+Shift+R 跳转类型、函数、macro 等
├── Symbol List - Marks.tmPreferences  # MARK 导航：在 Cmd+R 中将 // MARK: - xxx 转换为分隔标题
├── tests/
│   └── syntax_test_swift.swift        # 官方格式的自动化语法高亮 Scope 断言测试套件
├── scripts/
│   └── install_macos.sh               # 本机 macOS Sublime Text 软链接安装脚本
├── doc/
│   └── MAINTENANCE.md                 # 本维护文档（已通过 .gitattributes 从发布包排除）
├── .gitattributes                     # 控制 git archive 打包时剔除 tests/、scripts/、doc/ 等目录
├── .gitignore                         # 忽略缓存文件与构建产物
├── LICENSE                            # MIT 开源协议
└── README.md                          # 插件主页说明文档（Package Control 页面直接渲染此文件）
```

> **打包说明**：通过 [`.gitattributes`](../.gitattributes) 的 `export-ignore` 配置，当 GitHub 为版本 Tag 生成发布压缩包时，`tests/`、`scripts/`、`doc/`、`.gitignore`、`.gitattributes` 会被自动剔除。最终用户通过 Package Control 下载到的 `.sublime-package` 仅包含根目录下的 7 个核心文件。

---

### 2. 已支持的语言特性清单（截至 v1.0.0）

| 模块 | 已支持的具体语法 | 核心 Scope 命名 |
| :--- | :--- | :--- |
| **并发与隔离** | `async`, `reasync`, `await`, `actor`, `distributed actor`, `sending`, `isolated`, `nonisolated`, `nonisolated(unsafe)`, `nonisolated(nonsending)`, `#isolation`, `@isolated(any)`, `@MainActor`, `@Sendable`, `Sendable`, `SendableMetatype` | `storage.modifier.async.swift`, `storage.modifier.concurrency.swift`, `storage.type.actor.swift`, `keyword.control.flow.await.swift`, `variable.language.isolation.swift` |
| **宏系统 (Macros)** | `macro` 声明、`@freestanding(...)`、`@attached(...)`、`#externalMacro`、编译期宏展开（`#expect`, `#require`, `#Preview`, `#Predicate` 及自定义 `#macro`） | `storage.type.macro.swift`, `entity.name.function.macro.swift`, `variable.annotation.macro.swift`, `support.function.macro.swift` |
| **错误处理** | Swift 6 类型化抛出 `throws(ErrorType)`、普通 `throws` / `rethrows`、`do` / `try` / `try?` / `try!` / `catch` / `throw` | `keyword.control.exception.throws.swift`, `meta.throws.typed.swift`, `keyword.control.exception.swift` |
| **所有权与抑制约束** | `~Copyable`, `~Escapable`, `~BitwiseCopyable`, `borrowing`, `consuming`, `inout`, `yielding`, `consume`, `copy`, `discard self` | `meta.generic-constraint.suppressed.swift`, `storage.modifier.ownership.swift`, `keyword.operator.word.ownership.swift` |
| **泛型与参数包** | `some Protocol`, `any Protocol`, 参数包 `each T` 与 `repeat each x`（已与 `repeat { ... } while` 循环区分） | `storage.modifier.type.swift`, `keyword.operator.pack.swift` |
| **访问控制与模块** | `open`, `public`, `package`, `internal`, `fileprivate`, `private`（含 `...(set)` 形式），以及 Swift 6 访问级别导入 `public/package/internal/fileprivate/private import` | `storage.modifier.access-control.swift`, `keyword.control.import.swift` |
| **字面量与正则** | 二进制 `0b` / 八进制 `0o` / 十六进制 `0x` / 十进制浮点与整数、单行/多行字符串 `"""..."""`、原始字符串 `#"..."#` 及插值 `\#(...)`、单行正则 `/.../`、扩展多行正则 `#/.../#` | `constant.numeric.*.swift`, `string.quoted.*.swift`, `meta.interpolation.swift`, `string.regexp.*.swift` |
| **注释与导航标签** | 单行注释 `//`、文档注释 `///` 与 `/** ... */`、支持多层嵌套的块注释 `/* /* ... */ */`、Xcode 风格 `// MARK: -` / `TODO:` / `FIXME:` | `comment.*.swift`, `entity.name.section.mark.swift` |
| **标准库类型与函数** | 涵盖 Swift 6 新增的 `InlineArray`, `Span`, `RawSpan`, `MutableSpan`, `Mutex`, `Atomic`, `ObservationRegistrar`, `ContinuousClock`, `Duration`, `TaskGroup`, `Int128`, `UInt128` 等 | `support.type.swift`, `support.function.builtin.swift` |

---

## 三、本地开发与测试环境

### 1. 本地生效方式（软链接 vs Package Control）

- **本地开发模式**：运行 `./scripts/install_macos.sh` 会在 `~/Library/Application Support/Sublime Text/Packages/Swift` 创建指向本仓库的软链接。此时修改仓库中的 `Swift.sublime-syntax` 或 `.tmPreferences` 保存后，Sublime Text 会**实时热重载**，无需重启编辑器。
- **切换到 Package Control 正式版**：当官方合并收录 PR 后，如果希望本机改用 Package Control 自动更新的 `Swift6`，请先移除本地软链接，避免两份语法同时存在：
  ```bash
  rm "$HOME/Library/Application Support/Sublime Text/Packages/Swift"
  ```
  随后在 Sublime Text 中通过 `Cmd+Shift+P` -> `Package Control: Install Package` -> 安装 `Swift6`。
  *(未来若需再次本地开发，先在 Package Control 中 `Remove Package: Swift6`，再运行 `./scripts/install_macos.sh` 即可。)*

### 2. 如何查看光标处的 Scope 与调试语法

在 Sublime Text 中打开任意 `.swift` 文件：
- 按下快捷键 **`Ctrl+Opt+Cmd+P`**（macOS）或通过命令面板运行 **`Show Scope Name`**，即可在弹出框中查看当前光标位置的完整 Scope 层级链。

### 3. 如何运行自动化语法测试

每次修改 [`Swift.sublime-syntax`](../Swift.sublime-syntax) 后：
1. 在 Sublime Text 中打开 [`tests/syntax_test_swift.swift`](../tests/syntax_test_swift.swift)。
2. 按下 `Cmd+Shift+P` 打开命令面板，选择 **`Build With: Syntax Tests`**。
3. 底部构建面板输出 `Success: ... assertions in 1 file passed` 即代表所有语法高亮断言通过。

---

## 四、后续如何扩展新语法（常见场景速查）

当未来 Swift 发布新版本（如 Swift 6.3 / Swift 7）时，通常只需在 [`Swift.sublime-syntax`](../Swift.sublime-syntax) 的对应位置追加关键字：

1. **新增修饰符（如并发或所有权修饰符）**：
   - 在 `declarations` 上下文下找到 `storage.modifier.concurrency.swift` 或 `storage.modifier.ownership.swift` 或 `storage.modifier.swift` 的正则列表 `\b(...)\b`，用 `|` 追加新关键字即可。
2. **新增控制流关键字**：
   - 在 `statements` 上下文下找到 `keyword.control.conditional.swift` / `keyword.control.flow.swift` 追加。
3. **新增内置类型（标准库新类型）**：
   - 在 `types` 上下文下的 `support.type.swift` 正则列表中追加类型名。
4. **新增 `#xxx` 编译期指令或内置宏**：
   - 在 `pound-expressions` 或 `preprocessor` 上下文下追加。
   - **注意**：普通自定义或标准库独立宏（如 `#myNewMacro(...)`）已由通用规则 `(#)({{ident}})` 自动匹配，无需手动添加。
5. **重要注意事项**：
   - Sublime Text 的 `.sublime-syntax` 引擎**不支持**跨 `push` 上下文引用父级正则表达式的捕获组（如 `\1`）。凡是涉及成对可变分隔符（如 `#` 数量配对），请像现有的原始字符串规则一样使用显式分支匹配。

---

## 五、版本发布流程（同步至 Package Control）

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

由于配置了 `"tags": true`，**后续发布新版本完全不需要再向 `package_control_channel` 提 PR**，只需在本仓库执行以下标准流程：

1. **修改代码并通过测试**：
   在 Sublime Text 中运行 `Build With: Syntax Tests` 确认无报错。
2. **提交代码**：
   ```bash
   git add .
   git commit -m "Support Swift 6.x new keywords ..."
   ```
3. **打上新的语义化版本 Tag（SemVer）并推送**：
   查看当前最新 Tag（`git tag -l`），按语义化版本递增（例如 `1.0.1` 或 `1.1.0`，**保持不带 `v` 前缀的纯数字格式**）：
   ```bash
   git tag -a 1.1.0 -m "Release 1.1.0"
   git push origin main --tags
   ```
4. **验证打包内容（可选）**：
   本地可随时运行以下命令，预览 GitHub 打包给 Package Control 的最终文件列表：
   ```bash
   git archive --format=tar HEAD | tar -t
   ```
   推送 Tag 后，Package Control 服务器会在 1～2 小时内自动抓取新版本并推送给全球已安装 `Swift6` 的用户。
