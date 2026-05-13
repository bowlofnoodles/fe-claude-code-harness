<p align="center">
  <img src="https://img.shields.io/badge/React-61DAFB?style=for-the-badge&logo=react&logoColor=black" alt="React" />
  <img src="https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white" alt="TypeScript" />
  <img src="https://img.shields.io/badge/Vite-646CFF?style=for-the-badge&logo=vite&logoColor=white" alt="Vite" />
  <img src="https://img.shields.io/badge/Tailwind_CSS-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white" alt="Tailwind CSS" />
  <img src="https://img.shields.io/badge/Zustand-443E38?style=for-the-badge&logo=react&logoColor=white" alt="Zustand" />
  <img src="https://img.shields.io/badge/pnpm-F69220?style=for-the-badge&logo=pnpm&logoColor=white" alt="pnpm" />
  <img src="https://img.shields.io/badge/Claude_Code-CC9B7A?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Code" />
</p>

<h1 align="center">Fe Claude Code Harness</h1>

<p align="center">
  <strong>可复用的前端项目模板，集成 Claude Code harness + Superpowers + OpenSpec</strong>
</p>

<p align="center">
  <a href="#-前置要求">前置要求</a> &bull;
  <a href="#-快速开始">快速开始</a> &bull;
  <a href="#-开发工作流">工作流</a> &bull;
  <a href="#-命令参考">命令</a> &bull;
  <a href="#%EF%B8%8F-核心工具链">工具链</a> &bull;
  <a href="#-配置">配置</a>
</p>

---

## :white_check_mark: 前置要求

| 依赖 | 安装方式 |
|------|---------|
| Node.js >= 20.19.0 | [nodejs.org](https://nodejs.org) |
| pnpm | `npm install -g pnpm` |
| [Claude Code](https://claude.ai/code) | `npm install -g @anthropic-ai/claude-code` |
| [OpenSpec](https://github.com/Fission-AI/OpenSpec) | `npm install -g @fission-ai/openspec@latest` |
| [Superpowers](https://github.com/obra/superpowers) | `/plugin install superpowers@claude-plugins-official` |

---

## :zap: 快速开始

### :sparkles: 新项目（React + Vite + Tailwind）

一键创建全新项目，自带完整技术栈和 harness 配置：

```bash
# 远程一键安装
curl -fsSL https://raw.githubusercontent.com/bowlofnoodles/fe-claude-code-harness/main/install.sh | bash -s -- my-new-app


```
``` bash
# 或者先克隆再执行
git clone git@github.com:bowlofnoodles/fe-claude-code-harness.git
cd fe-claude-code-harness
./install.sh my-new-app
```

<details>
<summary>:mag: <code>install.sh</code> 做了什么</summary>

| 步骤 | 操作 |
|:----:|------|
| 1 | :package: 创建 Vite + React + TypeScript 项目 |
| 2 | :link: 安装依赖（React Router、Zustand、Tailwind、Vitest 等） |
| 3 | :wrench: 配置 TypeScript 路径别名（`@/`） |
| 4 | :file_folder: 创建项目目录结构 |
| 5 | :robot: 复制 Claude Code harness（`.claude/`、`CLAUDE.md`） |
| 6 | :scroll: 全局安装 OpenSpec + `openspec init` |
| 7 | :sparkles: 通过 Claude CLI 安装 Superpowers 插件 |
| 8 | :octocat: 初始化 git 并提交 |

</details>

### :syringe: 存量项目(任意技术栈)

已有项目只需注入 harness 骨架,不改动项目代码和依赖:

```bash
# 在项目根目录执行
curl -fsSL https://raw.githubusercontent.com/bowlofnoodles/fe-claude-code-harness/main/install.sh | bash -s -- --inject

```
``` bash
# 或者
cd my-existing-project
/path/to/install.sh --inject
```

#### 前端代码在子目录的情况

如果你的前端代码不在仓库根目录,而是在 `fe/` 或 `frontend/` 等子目录中:

```bash
# 在仓库根目录执行,指定前端代码目录
curl -fsSL https://raw.githubusercontent.com/bowlofnoodles/fe-claude-code-harness/main/install.sh | bash -s -- --inject fe

```
``` bash
# 或者本地执行
cd /path/to/repo-root
./install.sh --inject fe
```

这样会:
- 在仓库根目录创建 `.claude/` 目录
- 在 `settings.json` 中设置 `FRONTEND_DIR` 环境变量指向前端目录
- 在 `CLAUDE.md` 中注明前端代码位置
- `/init-project` 会自动从正确的目录读取配置

<details>
<summary>:mag: <code>--inject</code> 做了什么</summary>

| 步骤 | 操作 |
|:----:|------|
| 1 | :robot: 注入 `.claude/` 目录（commands、agents、通用 rules） |
| 2 | :page_facing_up: 创建骨架 `CLAUDE.md`（待 `/init-project` 填充） |
| 3 | :shield: 创建最小化 `settings.json`（通用权限） |
| 4 | :scroll: 安装 OpenSpec + `openspec init` |
| 5 | :sparkles: 安装 Superpowers 插件 |

**不会**：修改项目代码、安装依赖、改动配置文件、覆盖已有 `.claude/settings.local.json`

</details>

注入后打开 Claude Code，执行 `/noodles:init-project`：

```bash
claude
# 在 Claude Code 中执行：
/noodles:init-project
```

`/noodles:init-project` 会自动：
- 读取 `package.json`、`tsconfig.json`、配置文件等
- 识别框架、构建工具、包管理器、测试框架、样式方案
- 生成定制化的 `CLAUDE.md`（正确的命令和规范）
- 生成匹配技术栈的 `.claude/rules/`（如 Vue 项目生成 Vue 规范，非 Tailwind 项目不生成 Tailwind 规则）
- 更新 `settings.json` 权限（匹配实际的包管理器）

> :bulb: 如果 Superpowers 自动安装失败，在 Claude Code 中手动执行：
> ```
> /plugin install superpowers@claude-plugins-official
> ```


---

## :repeat: 开发工作流

### :star2: 功能开发（`/noodles:new-feature`）

核心流程将 Superpowers 脑暴与 OpenSpec 规格驱动开发串联起来：

```
                    /noodles:new-feature "用户登录页"
                              |
                +-------------+-------------+
                |  阶段 1：脑暴              |
                |  superpowers:brainstorming |
                |  探索需求、边界情况、用户流  |
                +-------------+-------------+
                              |
                +-------------+-------------+
                |  阶段 2：OpenSpec 提案      |
                |  /opsx:propose             |
                |  -> proposal.md            |
                |  -> specs/ (Given/When/Then)|
                |  -> design.md              |
                |  -> tasks.md               |
                |  用户审核并确认              |
                +-------------+-------------+
                              |
                +-------------+-------------+
                |  阶段 3：实现               |
                |  /opsx:apply + TDD         |
                |  superpowers:tdd 逐项实现   |
                +-------------+-------------+
                              |
                +-------------+-------------+
                |  阶段 4：验证 & 交付        |
                |  /opsx:verify              |
                |  superpowers:verification  |
                |  lint + types + test + build|
                |  /opsx:archive             |
                +---------------------------+
```

### :bug: 修复 Bug（`/noodles:debug`）

```
/noodles:debug "登录后页面白屏"
    |
    +-- 复现  -> 确认 bug 可以稳定触发
    +-- 定位  -> superpowers:systematic-debugging
    +-- 修复  -> 最小化根因修改
    +-- 验证  -> superpowers:verification-before-completion
```

### :art: 设计系统（`/noodles:design-system`）

```
/noodles:design-system init
    |
    +-- 个人项目？ -> 从 getdesign.md 获取设计 token
    +-- 客户项目？ -> 从原型图提取设计 token
    +-- 写入 DESIGN.md（设计规范唯一来源）
    +-- 映射到 tailwind.config.ts
    +-- 生成基础组件（Button、Input、Card……）
```

### :briefcase: 业务知识澄清（`/noodles:clarify-business`）

```
/noodles:clarify-business "订单流程"
    |
    +-- 交互式问答，澄清领域术语和业务规则
    +-- 核心规则   -> .claude/rules/business-context.md（自动加载）
    +-- 详细文档   -> docs/business/[domain].md（按需读取）
```

---

## :keyboard: 命令参考

> 📖 **完整使用文档**：查看 [HARNESS_USAGE.md](./HARNESS_USAGE.md) 获取详细的命令说明、工作流程和最佳实践。

### :robot: Claude Code 命令

| 命令 | 说明 |
|------|------|
| `/noodles:init-project` | 自动检测技术栈，生成定制化 `CLAUDE.md` + rules（存量项目必用） |
| `/noodles:new-feature <描述>` | 完整流程：脑暴 -> OpenSpec 提案 -> 实现 -> 交付 |
| `/noodles:debug <描述>` | 系统化调试：复现 -> 定位 -> 诊断 -> 修复 -> 验证 |
| `/noodles:design-system <名称\|init>` | 初始化设计系统或新增组件 |
| `/noodles:clarify-business <主题>` | 交互式问答，记录业务领域知识 |
| `/noodles:quality-check` | 运行 lint、type-check、test、build 全部质量门禁 |

### :scroll: OpenSpec 命令

| 命令 | 说明 |
|------|------|
| `/opsx:propose <描述>` | 生成结构化规格：proposal、specs、design、tasks |
| `/opsx:apply` | 按 tasks.md 实现变更 |
| `/opsx:verify` | 验证实现是否符合规格 |
| `/opsx:archive` | 归档变更，合并 delta specs 到主规格 |

### :sparkles: Superpowers Skills（自动触发）

| Skill | 触发时机 |
|-------|---------|
| `brainstorming` | 开始任何创造性工作或新功能 |
| `writing-plans` | 多步骤任务需要计划时 |
| `test-driven-development` | 实现功能或修复 bug 时 |
| `systematic-debugging` | 遇到 bug 或异常行为时 |
| `verification-before-completion` | 即将声称工作完成时 |
| `requesting-code-review` | 完成功能、合并前 |
| `subagent-driven-development` | 独立任务可并行执行时 |

---

## :gear: 核心工具链

本模板集成三套系统协同工作：

```
Superpowers 管理 agent 如何思考和工作（HOW）
OpenSpec 管理规划和文档（WHAT）

脑暴 (Superpowers)  ->  提案 (OpenSpec)  ->  实现 (Both)  ->  交付 (Both)
    ^ 探索意图           ^ 形式化规格        ^ TDD + 任务     ^ 验证 + 归档
```

### :muscle: [Superpowers](https://github.com/obra/superpowers) — AI 编码技能框架

Superpowers 是一个 agentic skills 框架（155k+ stars），为 Claude Code 提供结构化的开发工作流。

**安装**（在 Claude Code 中执行）：
```
/plugin install superpowers@claude-plugins-official
```

### :clipboard: [OpenSpec](https://github.com/Fission-AI/OpenSpec) — 规格驱动开发

OpenSpec 将规划结构化为正式的、可审查的产物：`proposal.md` -> `specs/` -> `design.md` -> `tasks.md`

**安装**：
```bash
npm install -g @fission-ai/openspec@latest
```

---

## :open_file_folder: Harness 目录结构

```
.claude/
├── settings.json                  # 权限、hooks、环境配置
├── rules/                         # 上下文感知规则（自动激活）
│   ├── frontend-conventions.md    # React + Tailwind 编码规范
│   ├── state-management.md        # Zustand 状态管理规范
│   ├── openspec-workflow.md       # OpenSpec 规则和目录布局
│   ├── debugging.md               # 5 步调试协议
│   ├── testing-strategy.md        # 测试策略：什么时候必须写测试、TDD 流程
│   └── git-workflow.md            # 分支和提交规范
├── commands/                      # 斜杠命令（工作流）
│   ├── init-project.md             # /init-project — 自动检测技术栈，生成配置
│   ├── new-feature.md             # /new-feature — 完整功能开发流程
│   ├── debug.md                   # /debug — 系统化 bug 修复
│   ├── design-system.md           # /design-system — 初始化或扩展设计系统
│   ├── clarify-business.md        # /clarify-business — 记录业务领域知识
│   └── quality-check.md           # /quality-check — 运行全部质量门禁
└── agents/                        # 子代理
    ├── component-builder.md       # 构建 UI 组件（使用 Sonnet）
    └── feature-reviewer.md        # 代码审查（自动触发）
```

---

## :shield: Rules 规则

`.claude/rules/` 中的规则用 `<important if="...">` 标签包裹——只在 Claude 处理相关任务时激活，保持 context 干净聚焦。

| 规则 | 激活条件 |
|------|---------|
| `frontend-conventions.md` | 编写 React / UI 代码时 |
| `state-management.md` | 操作 Zustand store 时 |
| `openspec-workflow.md` | 规划功能或编写规格时 |
| `debugging.md` | 调查 bug 或错误时 |
| `testing-strategy.md` | 写新代码、修 bug、重构时 |
| `git-workflow.md` | 提交代码或创建分支时 |

---

## :busts_in_silhouette: Agents 子代理

| Agent | 模型 | 用途 |
|-------|------|------|
| `component-builder` | Sonnet | 按设计系统规范构建 UI 组件 |
| `feature-reviewer` | Sonnet | 自动审查已完成的功能 |

子代理使用 Sonnet 模型，在保证质量的同时节省 token。

---

## :art: 设计系统策略

| 项目类型 | 设计来源 | 产出 |
|:--------:|---------|------|
| :house: 个人项目 | [getdesign.md](https://getdesign.md) | `DESIGN.md` -> `tailwind.config.ts` |
| :office: 客户项目 | 原型图 / 设计稿 | `DESIGN.md` -> `tailwind.config.ts` |

执行 `/design-system init` 生成 `DESIGN.md` 和基础组件（`Button`、`Input`、`Card` 等）

---

## :wrench: 配置

### settings.json 亮点

| 功能 | 说明 |
|------|------|
| :broom: 自动格式化 | PostToolUse hook 在每次文件编辑后运行 Prettier |
| :lock: 权限管理 | 常用开发命令预授权，危险操作需确认 |

### 自定义

- 编辑 `.claude/settings.json` 配置团队共享设置
- 创建 `.claude/settings.local.json` 配置个人覆盖（已 git-ignored）

---

## :pray: 致谢

- :brain: Harness 模式参考自 [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice)
- :sparkles: Skills 能力由 [Superpowers](https://github.com/obra/superpowers) 提供
- :clipboard: 规格驱动开发由 [OpenSpec](https://github.com/Fission-AI/OpenSpec) 提供

---

## :page_facing_up: 许可证

MIT
