---
description: Start a new feature — brainstorm → OpenSpec propose → implement → ship
argument-hint: [feature-description]
---

## New Feature Workflow

Feature: **$ARGUMENTS**

Follow this workflow strictly. Each phase must complete before moving to the next.

---

### Phase 1: Brainstorm
1. Use the `superpowers:brainstorming` skill to explore the problem space
2. Clarify requirements, edge cases, user flows with the user
3. If personal project: check design spec from getdesign.md
4. If client project: analyze prototype/mockup for design constraints
5. Output: clear understanding of WHAT to build and WHY

---

### Phase 2: OpenSpec Propose
**This is the critical planning phase. Do NOT skip.**

1. Run `/opsx:propose` with the feature description to create a structured change:
   - `proposal.md` — intent, scope, rationale
   - `specs/` — behavioral requirements in Given/When/Then format
   - `design.md` — technical approach, component breakdown, data flow
   - `tasks.md` — implementation checklist

2. Review the generated artifacts with the user:
   - Are the specs complete? Any missing scenarios?
   - Does the design align with the project's conventions?
   - Are the tasks granular enough (each < 50% context)?

3. Iterate on artifacts until the user approves

---

### Phase 3: Implement
1. Run `/opsx:apply` to start implementing from tasks.md
2. Use TDD where applicable — write tests before implementation
3. For UI components: delegate to `component-builder` agent if appropriate
4. Start dev server (`npm run dev`) and verify visually for any UI work

---

### Phase 4: Verify & Ship
1. Run `/opsx:verify` to validate implementation matches specs
2. Run quality gates: `npm run lint && npm run type-check && npm run test`
3. Use `superpowers:verification-before-completion` to confirm everything works
4. Run `/opsx:archive` to finalize the change and sync specs
5. Commit with conventional commit format
