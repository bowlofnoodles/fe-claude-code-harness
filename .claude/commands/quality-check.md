---
description: Run full quality gates and fix any issues found
---

## Quality Check

Run all quality gates and report results:

```bash
npm run lint
npm run type-check
npm run test
npm run build
```

For each failure:
1. Read the error output
2. Fix the issue
3. Re-run that specific check
4. Move to the next check

Report a summary at the end:
- Lint: PASS/FAIL (issues found/fixed)
- Types: PASS/FAIL (issues found/fixed)
- Tests: PASS/FAIL (X passed, Y failed)
- Build: PASS/FAIL
