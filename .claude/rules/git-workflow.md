<important if="committing code, creating branches, or managing git">

## Git Workflow

- Branch from `main` — naming: `feat/`, `fix/`, `refactor/`, `chore/`
- Conventional commits: `feat: add user profile page`, `fix: resolve hydration mismatch`
- One logical change per commit, not one file per commit
- Run `pnpm lint && pnpm type-check && pnpm test` before committing
- Squash merge feature branches to main
- Never force-push to main

</important>
