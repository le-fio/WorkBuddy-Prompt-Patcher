---
AIGC:
  ContentProducer: '001191110102MAD55U9H0F10002'
  ContentPropagator: '001191110102MAD55U9H0F10002'
  Label: '1'
  ProduceID: 'f9f66240-4af7-4409-b836-aeb3fa2675bb'
  PropagateID: 'f9f66240-4af7-4409-b836-aeb3fa2675bb'
  ReservedCode1: 'dbfc04bf-9288-46b2-85dd-ee47a097b99d'
  ReservedCode2: 'dbfc04bf-9288-46b2-85dd-ee47a097b99d'
---

# 🛡️ WorkBuddy Prompt Patcher (WorkBuddy 提示词破甲与管理工具)

一个用于对 **WorkBuddy** 桌面客户端底层系统提示词（System Prompt）进行一键备份、解除网络安全与逆向工程限制（破甲）以及自定义策略替换的轻量级开源工具。

---

## 🔬 破甲原理与底层机制 (How It Works)

WorkBuddy 作为一个基于 Electron 框架构建的桌面 AI 客户端，其大语言模型（LLM）的系统行为受底层模板控制。

### 1. 为什么“对话层越狱提示词”经常失效？
原厂客户端在每次向大模型发送请求前，都会在后台隐式注入一系列高优先级的系统级安全条文（System Prompt）。即使在对话框中使用类似“假假面/角色扮演”的越狱提示词，原厂注入的系统规则依然会与用户指令产生冲突，导致模型在处理代码审计、漏洞分析或逆向工程时触发拒绝应答。

### 2. 本工具的硬破甲原理
本工具通过 **“工程文件硬修改 (Hard Template Patching)”** 技术，直接在客户端侧对生成的物理模板进行源头解封：

1. **模板解封**：自动扫描并解析 `resources/app.asar.unpacked/resources/templates/` 目录下的底层模板。
2. **安全策略替换**：精准识别模板中的 `<content_policy>` 约束节点，将其替换为包含“沙盒环境声明”与“网安/逆向研究豁免（Research Exemption）”的全新策略。
3. **直接生效**：模板文件为 unpacked 明文，修改即生效，**无需重新打包 `app.asar`**（旧版需 repack 的说明已过时）。
4. **效果**：大语言模型从初始化的第一秒起，接收到的系统上下文就不再包含原厂的限制性条文，从根源上彻底解除了工具调用与安全回答的卡扣。

---

## 📂 涉及与修改的文件清单 (Affected Files)

本工具在运行过程中涉及与修改的所有文件均位于目标机器的 WorkBuddy 安装资源目录中（如 `.../WorkBuddy/resources/`）：

| 序号 | 目标文件 / 目录路径 (相对资源目录) | 操作类型 | 文件用途与改动说明 |
| :--- | :--- | :--- | :--- |
| **1** | `app.asar.unpacked/resources/templates_backup/` | **[新建备份]** | 第一次运行破甲或备份命令时，自动将官方原始模板完整复制保存于此，用于一键恢复。 |
| **2** | `app.asar.unpacked/resources/templates/workbuddy-prompt.tpl` | **[物理修改]** | 通用基础系统提示词模板，将内部 `<content_policy>` 节点替换为开放安全策略。 |
| **3** | `app.asar.unpacked/resources/templates/workbuddy-ask-prompt.tpl` | **[物理修改]** | Ask (问答模式) 系统提示词模板，更新安全策略。 |
| **4** | `app.asar.unpacked/resources/templates/workbuddy-ask-coding-prompt.tpl` | **[物理修改]** | Ask Coding (代码问答) 系统提示词模板，更新安全策略。 |
| **5** | `app.asar.unpacked/resources/templates/workbuddy-craft-coding-prompt.tpl` | **[物理修改]** | Craft Coding (深度编程与重构) 系统提示词模板，更新安全策略。 |
| **6** | `app.asar.unpacked/resources/templates/workbuddy-craft-design-prompt.tpl` | **[物理修改]** | Craft Design (架构与 UI 设计) 系统提示词模板，更新安全策略。 |
| **7** | `app.asar.unpacked/resources/templates/workbuddy-expert-prompt.tpl` | **[物理修改]** | Expert (专家模式) 系统提示词模板，更新安全策略。 |
| **8** | `app.asar.unpacked/resources/templates/workbuddy-expert-coding-prompt.tpl` | **[物理修改]** | Expert Coding (专家编程模式) 系统提示词模板，更新安全策略。 |
| **9** | 模板文件（写入后） | **[只读保护]** | 已注入模板自动设置只读属性（`chmod 0o444`），防止运行时复写；重复注入时自动解锁→写入→重新加锁。 |

> **注**：模板为 `app.asar.unpacked` 内的明文文件，修改后重启 WorkBuddy 即生效，无需重打包 `app.asar`。
>
> **⚠️ 升级须知**：WorkBuddy 自动升级（提权安装器）会整体替换 `app.asar.unpacked` 目录，**只读属性会被清除、注入会被还原**。每次客户端升级后请重新运行注入（见下方“升级后重新注入”）。

---

## ✨ 核心特性

- **0 硬编码，全平台动态自动匹配**：根据操作系统 (`win32` / `darwin` / `linux`) 及环境变量自动探测 WorkBuddy 客户端的安装路径，支持任意盘符与自定义安装位置。
- **双模式操作 - CLI + Web UI**：既支持命令行交互菜单，也提供浏览器 Web UI 界面，路径输入后自动持久化保存，下次打开无需重新输入。
- **一键备份保障**：自动创建官方原始提示词模板的独立备份，安全无忧。
- **网安与逆向破甲**：注入 Codex-5.5 / Unrestricted 风格的沙盒安全豁免策略，解除模型对代码审计、漏洞分析、逆向工程等合法科研行为的过度拦截。
- **版本化策略库**：内置多套可切换的安全豁免策略（V2 完全豁免版 / V3 授权沙盒协议版 / V3.1 5.4.7 兼容版 / OMN 叙事框架版），Web UI 与 CLI 均可一键切换，**默认 V3.1**。
- **只读保护**：注入后模板自动设为只读，防止运行时复写；重复注入幂等（自动解锁→写入→重新加锁）。
- **实时状态看板**：Web UI 模式下可查看模板总数、已破甲数量、只读数量、备份状态等信息。

---

## ⬆️ 升级后重新注入（重要）

WorkBuddy 自动升级时，提权安装器会整体替换 `app.asar.unpacked` 目录——**只读属性、注入内容、备份目录都会被清除**。升级后重新注入三步：

```bash
node server.js   # 或 node index.js，选策略 V3.1 执行注入
```

1. 完全退出 WorkBuddy（含托盘进程）→ 2. 运行注入（默认 V3.1）→ 3. 重启 WorkBuddy 开新会话。

策略设计说明：V3.1 与 5.4.7+ 平台合规红线（未成年人保护、政治主权、系统提示词保密）保持一致，仅在此前提下豁免成年虚构创作与授权安全研究——降低与升级器的对抗性，减少被整体替换的概率。详见 `WorkBuddy_Research_Notes.md` 第 4 节。

---

## 🛠️ 前置准备

### 环境要求
- 安装有 **Node.js** (v16+)
- 安装有 **asar** 命令行工具（用于 Electron 资源解包与重新打包）

```bash
npm install -g asar
```

---

## 🚀 快速使用

### 方式一：Web UI 模式（推荐）

```bash
git clone https://github.com/your-username/workbuddy-prompt-patcher.git
cd workbuddy-prompt-patcher
node server.js
```

启动后在浏览器中打开 `http://127.0.0.1:7474` 即可使用 Web 界面。路径输入后自动保存到浏览器本地存储，下次打开无需重新输入。Web UI 提供：

- **路径管理**：自动检测 + 手动输入 + localStorage 持久化
- **状态看板**：模板总数、已破甲数量、备份状态一目了然
- **模板清单**：查看每个模板文件的大小、修改时间、策略状态
- **操作面板**：四个卡片式按钮，点击即弹出确认窗口
- **实时日志**：终端风格的日志控制台，实时输出操作结果

### 方式二：CLI 命令行模式

```bash
git clone https://github.com/your-username/workbuddy-prompt-patcher.git
cd workbuddy-prompt-patcher
node index.js
```

启动后将自动检测您电脑上的 WorkBuddy 路径，并显示交互菜单：

```text
=================================================
   🛡️ WorkBuddy 提示词破甲与管理工具 (CLI)
=================================================
自动识别路径: /Applications/WorkBuddy.app/Contents/Resources (或 Windows/Linux 对应路径)
--------------------------------------------------
  1. 📦 备份当前所有提示词模板
  2. 🚀 一键替换为【网安/逆向研究破甲提示词】
  3. ✏️ 自定义输入安全提示词策略
  4. ⏪ 一键恢复官方原始备份提示词
  5. 📁 手动设置/修改 WorkBuddy 资源路径
  0. ❌ 退出
=================================================
```

### 菜单选项说明

* **1. 备份当前所有提示词模板**：在 WorkBuddy 资源目录下创建独立的 `templates_backup` 备份文件。
* **2. 一键替换为【网安/逆向研究破甲提示词】**：批量替换所有 `.tpl` 模板中的限制标记为无限制科研沙盒策略，写入后自动设只读。CLI 下会先弹出策略版本选择（V2 / V3 / V3.1 / OMN），Web UI 下可在弹窗中下拉选择。
* **3. 自定义输入安全提示词策略**：支持直接粘贴您自己编写的 `<content_policy>` 或 Jinja2 文本并一键打包。
* **4. 一键恢复官方原始备份提示词**：一键还原至官方初始模板状态。
* **5. 手动设置/修改 WorkBuddy 资源路径**：当自动检测未找到时，随时自定义指定资源路径。

---

## ⚠️ 注意事项与最佳实践

1. **推荐关闭客户端**：模板文件为明文直接写入，一般无需关闭客户端；如遇文件占用（升级过程中）请先彻底退出 WorkBuddy。
2. **生效应答**：修改完成后重新启动 WorkBuddy 客户端，开启**新的对话框**即可使全新的提示词策略生效。
3. **升级还原**：WorkBuddy 每次自动升级都会还原模板（提权安装器绕过只读），升级后重新注入即可，详见“升级后重新注入”。

---

## 📁 项目结构

```
workbuddy-prompt-patcher/
├── index.js          # CLI 命令行版本（原有）
├── server.js          # Web UI 服务器（新增）
├── public/
│   └── index.html     # Web UI 前端界面（新增）
├── package.json       # 项目元数据与启动脚本
├── README.md          # 说明文档
├── WorkBuddy_Research_Notes.md  # 研究笔记
└── LICENSE            # MIT 许可证
```

### npm 脚本快捷启动

```bash
npm start    # 启动 Web UI 服务器（等同于 node server.js）
npm run cli  # 启动 CLI 命令行菜单（等同于 node index.js）
```

---

## 📄 许可证

[MIT License](LICENSE)

> AI生成