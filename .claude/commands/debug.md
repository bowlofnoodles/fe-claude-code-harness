---
description: Debug and fix a bug using systematic debugging workflow
argument-hint: [bug-description]
---

## Debug Workflow

Bug report: **$ARGUMENTS**

Follow the systematic debugging protocol:

### Step 1: Reproduce
- Read the bug description carefully
- Identify the expected vs actual behavior
- If possible, start the dev server (`pnpm dev`) and reproduce in browser

### Step 2: Investigate
- Use the `superpowers:systematic-debugging` skill
- Check browser console, network tab, component tree
- Read relevant source code and recent git changes (`git log --oneline -20`)
- Form a hypothesis about the root cause

### Step 3: Fix
- Make the minimal change that fixes the root cause
- Don't refactor surrounding code unless it's part of the bug

### Step 4: Verify
- Reproduce the original issue — confirm it's fixed
- Run related tests: `pnpm test -- --reporter=verbose`
- Check for regressions in related features
- Use the `superpowers:verification-before-completion` skill before claiming done
