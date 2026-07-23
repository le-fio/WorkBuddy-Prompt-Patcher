# WorkBuddy 界面 Logo 替换与系统提示词 (System Prompt) 研究总结

> 本文档用于记录关于 WorkBuddy 客户端 Logo/图标替换技术方案，以及官方系统提示词（System Prompt）本地位置与社区研究的完整信息。

---

## 目录
1. [环境与安装路径](#1-环境与安装路径)
2. [WorkBuddy 图标黑化与 Logo 替换研究](#2-workbuddy-图标黑化与-logo-替换研究)
   - [2.1 问题原因分析](#21-问题原因分析)
   - [2.2 解决方案与 ASAR 解包重包流程](#22-解决方案与-asar-解包重包流程)
   - [2.3 生成的黑化版图标/SVG 文件绝对路径](#23-生成的黑化版图标svg-文件绝对路径)
   - [2.4 核心 ASAR 路径与备份文件](#24-核心-asar-路径与备份文件)
3. [WorkBuddy 系统提示词 (System Prompt) 位置研究](#3-workbuddy-系统提示词-system-prompt-位置研究)
   - [3.1 本地内置官方 Prompt 模板目录](#31-本地内置官方-prompt-模板目录)
   - [3.2 关键 `.tpl` 模板文件清单](#32-关键-tpl-模板文件清单)
   - [3.3 GitHub 提示词社区资源整理](#33-github-提示词社区资源整理)

---

## 1. 环境与安装路径

* **WorkBuddy 客户端真实安装路径（D盘）**：
  `D:\Users\31305\AppData\Local\Programs\WorkBuddy\`
* **资源文件目录**：
  `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\`

---

## 2. WorkBuddy 图标黑化与 Logo 替换研究

### 2.1 问题原因分析
* 替换根目录或外部的 `workbuddy.png` 只能改变系统的 **Alt+Tab 任务栏窗口图标**。
* **界面内左下角的个人头像**及不同皮肤/模式下的 Logo，是直接编译打包在前端静态资源库中的，存放在 `resources/app.asar` 归档文件内部。因此单独修改外部 PNG 无法改变界面 UI 元素。

### 2.2 解决方案与 ASAR 解包重包流程
由于 Windows 环境下的打包可能包含非本平台的二进制文件标识（如 `x64-linux`），使用默认 `npx asar extract` 命令可能会报错。我们采用了自定义 Node.js 脚本来完成解包与替换：
1. **备份原文件**：将 `app.asar` 备份为 `app.asar.bak`。
2. **容错解包**：运行自定义 Node.js 脚本解析 ASAR Header，将压缩包解压到 `resources/app_temp/`。
3. **批量覆盖**：扫描 `app_temp/dist/renderer/assets/` 及 `app.asar.unpacked/` 中所有带有 `logo`、`icon`、`workbuddy` 关键字的 PNG/JPG 文件，统一替换为新的黑化版图标。
4. **重新打包**：执行 `npx asar pack app_temp app.asar` 将修改后的前端资源重新打包。

### 2.3 生成的黑化版图标/SVG 文件绝对路径
所有的黑化版资源均保存在本地系统如下位置：

* **黑化版 PNG 高清图标**：
  `C:\Users\31305\.gemini\antigravity\brain\42fe466f-2049-4165-b657-d832887a35a1\evil_workbuddy_icon_1784799193360.png`

* **黑化版矢量 SVG (正方形 App Icon 版)**：
  `C:\Users\31305\.gemini\antigravity\brain\42fe466f-2049-4165-b657-d832887a35a1\evil_pwa-icon.svg`

* **黑化版矢量 SVG (宽屏 Logo 徽标版)**：
  `C:\Users\31305\.gemini\antigravity\brain\42fe466f-2049-4165-b657-d832887a35a1\evil_logo.svg`

### 2.4 核心 ASAR 路径与备份文件
* **当前生效的已修改核心包**：
  `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app.asar`
* **原始核心包安全备份**：
  `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app.asar.bak`
* **解压临时目录 (可选择清理)**：
  `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app_temp\`

### 2.5 识图精准比对与 3 种猫咪 Icon 替换记录

根据用户提供的 3 张截图，已完成底层 Asset 的识图精确匹配与覆盖：

| 用户截图 | 视觉特征与功能场景 | 对应的原程序资源文件 (绝对路径) |
| :--- | :--- | :--- |
| **图 1** | 绿色渐变背景圆角矩形，白猫头徽标 Logo | `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app_temp\renderer\assets\logo-workbuddy-BUNGQxi-.svg` |
| **图 2** | 紫/蓝渐变圆形背景，白猫头顶栏图标 | `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app_temp\renderer\assets\header-icon-dark-B6QVQZjG.svg` |
| **图 3** | 深灰/暗灰圆形背景，白猫头顶栏/对话图标 | `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app_temp\renderer\assets\header-icon-DKPVU6OC.svg`<br>`D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app_temp\renderer\assets\header-cat-icon-DcTQ87UT.svg` |
| **左下角头像** | 默认用户个人中心头像图片 (PNG) | `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app_temp\renderer\assets\default-account-logo-DBnjou1P.png` |

### 2.7 App 文件夹明文挂载模式与命令行 DevTools 强启方案

为解决最新版客户端可能忽略 `app.asar` 修改或屏蔽快捷键的问题，实施了以下高级挂载与调试方案：

1. **App 文件夹明文挂载模式 (Folder Mode)**：  
   在 Electron 架构中，如果 `resources/app` 文件夹存在，客户端会优先加载 `app` 目录中的源码与静态文件，从而跳过 `app.asar`。  
   * **已重命名包**：将 `app.asar` 改名暂存为 `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app.asar.disabled`。  
   * **生成明文目录**：将修改后的代码创建为原生明文目录 `D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app\`。

2. **命令行附加调试参数强启 DevTools (CLI Debug Method)**：  
   如果快捷键被新版本拦截，可通过在启动指令中添加 Electron 官方远程调试参数强制切出控制台：  
   * **带参数启动指令**：  
     `"D:\Users\31305\AppData\Local\Programs\WorkBuddy\WorkBuddy.exe" --remote-debugging-port=9222 --auto-open-devtools-for-tabs`
   * **浏览器远程审查接口**：在 Chrome / Edge 中访问 `http://localhost:9222` 或 `chrome://inspect` 即可审查客户端全部 UI 节点。

## 3. WorkBuddy 系统提示词 (System Prompt) 位置研究

### 3.1 本地内置官方 Prompt 模板目录
WorkBuddy 官方的底层 Prompt 无需从外部泄露，其所有的系统级 Prompt 模板都以明文形式存放于客户端的解包目录中：

📁 **完整绝对路径**：
`D:\Users\31305\AppData\Local\Programs\WorkBuddy\resources\app.asar.unpacked\resources\templates\`

### 3.2 关键 `.tpl` 模板文件清单

| 文件名 | 用途与功能说明 |
| :--- | :--- |
| `workbuddy-prompt.tpl` | 通用基础系统提示词 (General System Prompt) |
| `workbuddy-ask-prompt.tpl` | Ask 提问模式提示词 |
| `workbuddy-ask-coding-prompt.tpl` | Ask 编码问答模式提示词 |
| `workbuddy-craft-coding-prompt.tpl` | Craft 深度编程与重构模式提示词 |
| `workbuddy-craft-design-prompt.tpl` | Craft 架构与 UI 设计模式提示词 |
| `workbuddy-expert-prompt.tpl` | 专家模式通用提示词 |
| `workbuddy-expert-coding-prompt.tpl` | 专家模式编程提示词 |

此外，在 `templates/style/` 目录下还包含控制 AI 语气与性格的偏好模版：
* `style-professional.md` (专业风格)
* `style-friendly.md` (友好风格)
* `style-sarcastic.md` (讽刺幽默风格)
* `style-socratic.md` (苏格拉底式引导风格)
* `style-efficient.md` (高效风格)
* `style-straightforward.md` (直来直往风格)
* `style-creative.md` (创意风格)

### 3.3 GitHub 提示词社区资源整理
如果在 GitHub 上寻找相关的开源 Prompt / Skill 资源，可以关注以下领域：
1. **[agency-agents-zh](https://github.com/jnMetaCode/agency-agents-zh)**：收录了适用于 WorkBuddy、Claude Code 的丰富中文 Agent 角色提示词。
2. **[learn-workbuddy 社区生态](https://github.com/topics/workbuddy)**：包含针对 WorkBuddy 的自定义 Skill 技能包 Prompt 编写规范。
3. **Karpathy 风格的 GUIDELINES 规范**：WorkBuddy 社区常用的系统规则规范（`GUIDELINES.zh.md`）。
