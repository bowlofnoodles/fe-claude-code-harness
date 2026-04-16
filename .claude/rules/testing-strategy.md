<important if="writing new code, fixing bugs, refactoring, or creating components/hooks/utils">

## Testing Strategy

### 什么时候必须写测试

| 场景 | 要求 | 测试类型 |
|------|------|---------|
| 新组件（`src/components/`） | **必须** | 单元测试：渲染、交互、props 变体 |
| 新 hook（`src/hooks/`） | **必须** | 单元测试：输入输出、状态变更、边界情况 |
| 新 util/helper（`src/lib/`） | **必须** | 单元测试：输入输出、边界值 |
| 新 feature 核心逻辑 | **必须** | 单元测试：业务规则、状态流转 |
| Bug fix | **必须** | 先写一个能复现 bug 的失败测试，再修复使其通过 |
| Zustand store | **建议** | 状态变更测试：actions、selectors |
| 页面/路由级组件 | **建议** | 集成测试：关键用户流程 |
| 纯样式调整/布局修改 | **不需要** | — |
| 重构 | **不新增** | 现有测试必须全部通过 |

### TDD 流程（必须场景）

对于上表中标记「必须」的场景，严格遵循 Red-Green-Refactor：

1. **Red** — 写一个描述预期行为的测试，运行确认它失败
2. **Green** — 写最少的代码让测试通过
3. **Refactor** — 在测试保护下重构实现

### 测试文件规范

- 共置：`ComponentName.test.tsx` 放在组件同目录下
- 命名：`describe('ComponentName')` → `it('should ...')`
- 工具：Vitest + React Testing Library
- 不要 mock 除了外部 API 之外的东西——优先测真实行为
- 不要测实现细节（内部 state、私有方法），只测外部可观察行为

### Bug Fix 测试模式

```tsx
// 1. 先写失败测试，证明 bug 存在
it('should not crash when user has no avatar', () => {
  // 这个测试在修复前应该失败
  render(<UserCard user={{ name: 'test', avatar: null }} />)
  expect(screen.getByText('test')).toBeInTheDocument()
})

// 2. 修复代码使测试通过
// 3. 这个测试永远留着，防止回归
```

### 质量门禁

提交前必须通过：`pnpm lint && pnpm type-check && pnpm test`

如果新增了「必须」场景的代码但没有对应测试，**不允许提交**。

</important>
