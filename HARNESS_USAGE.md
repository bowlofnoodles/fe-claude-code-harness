# Claude Code Harness 使用文档

本文档介绍如何使用此项目集成的 Claude Code harness，帮助你快速上手开发流程。

---

## :sparkles: 核心命令

### 项目初始化

| 命令 | 说明 | 使用场景 |
|------|------|---------|
| `/noodles:init-project` | 自动检测技术栈，生成定制化配置 | 注入 harness 后首次使用 |

**示例**：
```
/noodles:init-project
```

这个命令会：
- 分析 `package.json`、`tsconfig.json` 等配置文件
- 识别框架、构建工具、包管理器、测试框架
- 生成定制化的 `CLAUDE.md` 文档
- 生成匹配技术栈的 `.claude/rules/` 规则
- 更新权限配置

---

### 功能开发

| 命令 | 说明 | 阶段流程 |
|------|------|---------|
| `/noodles:new-feature <描述>` | 完整功能开发流程 | 脑暴 → 提案 → 实现 → 交付 |

**示例**：
```
/noodles:new-feature 用户登录页面
```

**工作流程**：
1. **脑暴阶段** — 使用 Superpowers brainstorming 探索需求
2. **OpenSpec 提案** — 自动运行 `/opsx:propose` 生成：
   - `proposal.md` — 需求和范围
   - `specs/` — 行为规格（Given/When/Then）
   - `design.md` — 技术设计
   - `tasks.md` — 实现任务清单
3. **实现阶段** — 运行 `/opsx:apply` 按任务清单实现
4. **验证交付** — 运行 `/opsx:verify` 和质量门禁，最后 `/opsx:archive` 归档

---

### Bug 修复

| 命令 | 说明 | 使用场景 |
|------|------|---------|
| `/noodles:debug <描述>` | 系统化调试流程 | 遇到 bug 或异常行为 |

**示例**：
```
/noodles:debug 登录后页面白屏
```

**调试流程**：
1. **复现** — 确认 bug 可稳定触发
2. **定位** — 使用 Superpowers systematic-debugging
3. **修复** — 最小化根因修改
4. **验证** — 先写失败测试，再修复代码使测试通过

---

### 设计系统

| 命令 | 说明 | 使用场景 |
|------|------|---------|
| `/noodles:design-system init` | 初始化设计系统 | 项目开始时建立设计规范 |
| `/noodles:design-system <组件名>` | 添加/扩展组件 | 需要新 UI 组件时 |

**示例**：
```
/noodles:design-system init
/noodles:design-system Button
```

**`init` 流程**：
1. 选择设计来源（个人项目用 getdesign.md，客户项目用原型图）
2. 提取设计 token（颜色、字体、间距、圆角、阴影等）
3. 生成 `DESIGN.md`（设计规范唯一来源）
4. 映射到 `tailwind.config.ts`
5. 创建基础组件（Button、Input、Card 等）

---

### 业务知识澄清

| 命令 | 说明 | 使用场景 |
|------|------|---------|
| `/noodles:clarify-business <主题>` | 交互式问答记录业务知识 | 需要理解业务领域术语和规则 |

**示例**：
```
/noodles:clarify-business 订单流程
```

**产出**：
- `.claude/rules/business-context.md` — 核心规则（自动加载）
- `docs/business/<domain>.md` — 详细文档（按需读取）

---

### 质量检查

| 命令 | 说明 | 使用场景 |
|------|------|---------|
| `/noodles:quality-check` | 运行所有质量门禁 | 提交代码前确保代码质量 |

**示例**：
```
/noodles:quality-check
```

**检查项**：
- Lint 检查（ESLint）
- 类型检查（TypeScript）
- 单元测试（Vitest/Jest）
- 构建验证

---

## :clipboard: OpenSpec 命令

OpenSpec 用于结构化的规格驱动开发，命令**不带前缀**：

| 命令 | 说明 |
|------|------|
| `/opsx:propose <描述>` | 创建变更提案（proposal + specs + design + tasks） |
| `/opsx:apply` | 按 tasks.md 实现变更 |
| `/opsx:verify` | 验证实现是否符合规格 |
| `/opsx:archive` | 归档变更，合并 delta specs 到主规格 |

**目录结构**：
```
openspec/
├── specs/              # 主规格（当前系统行为）
│   └── [domain]/
└── changes/            # 变更提案
    ├── [change-name]/
    │   ├── proposal.md
    │   ├── specs/      # Delta specs (ADDED/MODIFIED/REMOVED)
    │   ├── design.md
    │   └── tasks.md
    └── archive/        # 已完成的变更
```

---

## :repeat: 完整开发流程示例

### 场景：开发一个新功能「用户个人资料页」

#### 第 1 步：启动功能开发
```
/noodles:new-feature 用户个人资料页，支持编辑头像、昵称、邮箱
```

Claude 会：
1. 使用 Superpowers brainstorming 探索需求
2. 自动运行 `/opsx:propose` 创建提案
3. 生成 `openspec/changes/user-profile-page/` 目录，包含：
   - `proposal.md` — 需求说明
   - `specs/` — 行为规格
   - `design.md` — 技术设计
   - `tasks.md` — 任务清单

#### 第 2 步：审查提案
检查生成的文档，确认：
- 规格是否完整？
- 设计是否合理？
- 任务是否够细？

如需调整，直接让 Claude 修改相关文件。

#### 第 3 步：开始实现
```
/opsx:apply
```

Claude 会按 `tasks.md` 逐项实现，遵循 TDD 原则：
- 先写测试
- 再写实现
- 通过测试

#### 第 4 步：验证和交付
```
/opsx:verify
```

Claude 会：
1. 对照规格验证实现
2. 运行质量门禁
3. 确认所有测试通过

最后归档：
```
/opsx:archive
```

---

## :art: 设计系统工作流

### 初始化设计系统

#### 个人项目
```
/noodles:design-system init
```
选择 "personal project"，Claude 会从 getdesign.md 获取设计 token。

#### 客户项目
```
/noodles:design-system init
```
选择 "client project"，提供原型图链接，Claude 会提取设计 token。

### 添加新组件
```
/noodles:design-system Modal
```

Claude 会：
1. 读取 `DESIGN.md` 设计规范
2. 创建 `src/components/ui/Modal.tsx`
3. 遵循统一的 API 模式（variant、size props）
4. 编写组件测试
5. 更新组件导出

---

## :bug: Bug 修复流程

### 场景：登录后页面白屏

#### 第 1 步：启动调试
```
/noodles:debug 登录后页面白屏，控制台显示 Uncaught TypeError
```

#### 第 2 步：复现问题
Claude 会：
1. 启动 dev server
2. 尝试复现问题
3. 检查浏览器控制台、网络请求

#### 第 3 步：定位原因
使用 Superpowers systematic-debugging：
1. 分析错误堆栈
2. 检查相关源码
3. 查看最近的 git 提交
4. 形成根因假设

#### 第 4 步：修复和验证
1. **先写失败测试**，复现 bug
2. 修复代码，使测试通过
3. 运行所有测试，确保无回归
4. 使用 Superpowers verification-before-completion 最终确认

---

## :gear: 质量门禁

提交代码前，务必运行：

```bash
pnpm lint && pnpm type-check && pnpm test
```

或使用命令：
```
/noodles:quality-check
```

**检查项**：
- **Lint** — 代码风格和潜在问题
- **Type Check** — TypeScript 类型错误
- **Test** — 单元测试和集成测试
- **Build** — 生产构建是否成功

---

## :sparkles: Superpowers Skills

Superpowers 会自动在合适的时机触发相应的 skill：

| Skill | 触发时机 | 作用 |
|-------|---------|------|
| `brainstorming` | 开始创造性工作或新功能 | 探索问题空间，澄清需求 |
| `writing-plans` | 多步骤任务需要计划 | 生成结构化计划 |
| `test-driven-development` | 实现功能或修 bug | 强制 TDD 流程（红-绿-重构） |
| `systematic-debugging` | 遇到 bug 或异常 | 系统化调试方法 |
| `verification-before-completion` | 即将声称工作完成 | 全面验证工作成果 |
| `requesting-code-review` | 完成功能、合并前 | 自动代码审查 |
| `subagent-driven-development` | 独立任务可并行 | 并行执行多个子任务 |

---

## :file_folder: 目录结构说明

```
.claude/
├── settings.json              # 配置（权限、hooks、skillNamePrefix）
├── rules/                     # 上下文规则（自动激活）
│   ├── frontend-conventions.md
│   ├── state-management.md
│   ├── openspec-workflow.md
│   ├── debugging.md
│   ├── testing-strategy.md
│   └── git-workflow.md
├── commands/                  # 斜杠命令
│   ├── init-project.md
│   ├── new-feature.md
│   ├── debug.md
│   ├── design-system.md
│   ├── clarify-business.md
│   └── quality-check.md
└── agents/                    # 子代理
    ├── component-builder.md
    └── feature-reviewer.md

openspec/
├── specs/                     # 主规格（当前行为）
└── changes/                   # 变更提案

docs/
├── plans/                     # 计划文档
└── business/                  # 业务知识文档

src/
├── app/                       # 应用入口和路由
├── components/                # 共享组件
│   ├── ui/                    # 基础设计系统组件
│   └── layout/                # 布局组件
├── features/                  # 功能模块
├── hooks/                     # 自定义 Hooks
├── lib/                       # 工具函数、常量
│   └── stores/                # Zustand stores
├── styles/                    # 全局样式
├── types/                     # TypeScript 类型
└── assets/                    # 静态资源
```

---

## :notebook_with_decorative_cover: 核心规范

### 代码规范
- **语言**：TypeScript strict mode，禁止 `any`
- **组件**：函数组件 + 命名导出（无默认导出）
- **样式**：Tailwind utility classes，用 `cn()` 处理条件类名
- **状态**：Zustand（全局/共享），React state（本地），TanStack Query（服务端）
- **路由**：React Router v7 或配置在 `app/router.tsx`
- **命名**：PascalCase（组件），camelCase（函数/变量），kebab-case（文件）
- **导入**：绝对路径 `@/` 指向 `src/`

### 测试策略

| 场景 | 要求 | 说明 |
|------|------|------|
| 新组件/hook/util | **必须** | TDD：先写测试，再实现 |
| Bug fix | **必须** | 先写失败测试复现 bug，再修复 |
| 新 feature 核心逻辑 | **必须** | 单元测试覆盖业务规则 |
| 纯样式调整 | **不需要** | 无需测试 |

### Git 规范
- **分支**：`feat/xxx`、`fix/xxx`、`refactor/xxx`、`chore/xxx`
- **提交**：Conventional Commits（`feat:`、`fix:`、`chore:`等）
- **原则**：每次提交一个逻辑变更，不是一个文件

---

## :bulb: 最佳实践

### 1. 功能开发从 `/noodles:new-feature` 开始
不要跳过 OpenSpec 提案阶段，结构化的规划能避免返工。

### 2. 所有 UI 组件先读 `DESIGN.md`
设计规范是唯一真理来源，确保视觉一致性。

### 3. 遵循 TDD
组件、hooks、utils、核心逻辑必须先写测试。Bug 修复必须先写能复现 bug 的失败测试。

### 4. Bug 修复用 `/noodles:debug`
系统化流程能更快定位根因，避免瞎猜。

### 5. 提交前运行质量门禁
```bash
pnpm lint && pnpm type-check && pnpm test
```

### 6. 使用 `/compact` 管理上下文
当上下文使用超过 50% 时，运行 `/compact` 压缩历史。

---

## :question: 常见问题

### Q: 如何修改命令前缀？
A: 编辑 `.claude/settings.json`，修改 `skillNamePrefix` 字段：
```json
{
  "skillNamePrefix": "your-prefix",
  ...
}
```

### Q: 如何禁用自动格式化？
A: 编辑 `.claude/settings.json`，移除 `hooks.PostToolUse` 配置。

### Q: OpenSpec 命令为什么没有前缀？
A: OpenSpec 命令是全局命令，不属于项目 harness，因此不需要前缀。

### Q: 如何添加自定义命令？
A: 在 `.claude/commands/` 目录下创建新的 `.md` 文件，格式参考现有命令。

### Q: Superpowers 没有自动触发怎么办？
A: 确认已安装 Superpowers 插件：
```
/plugin install superpowers@claude-plugins-official
```

### Q: 如何跳过某个 rule？
A: Rules 通过 `<important if="...">` 标签条件激活，只在相关任务时生效，无需手动禁用。

---

## :link: 相关资源

- [Claude Code 官方文档](https://docs.anthropic.com/claude-code)
- [Superpowers GitHub](https://github.com/obra/superpowers)
- [OpenSpec GitHub](https://github.com/Fission-AI/OpenSpec)
- [Harness 最佳实践](https://github.com/shanraisshan/claude-code-best-practice)

---

## :tada: 快速参考卡片

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Claude Code Harness — 快速参考
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📦 项目初始化
  /noodles:init-project

  ✨ 功能开发
  /noodles:new-feature <描述>
  → 自动执行：brainstorm → /opsx:propose → /opsx:apply → /opsx:verify

  🐛 Bug 修复
  /noodles:debug <描述>

  🎨 设计系统
  /noodles:design-system init
  /noodles:design-system <组件名>

  💼 业务知识
  /noodles:clarify-business <主题>

  ✅ 质量检查
  /noodles:quality-check

  📋 OpenSpec（无前缀）
  /opsx:propose → /opsx:apply → /opsx:verify → /opsx:archive

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  质量门禁（提交前必跑）
  pnpm lint && pnpm type-check && pnpm test
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
