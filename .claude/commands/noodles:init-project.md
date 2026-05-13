---
description: Auto-detect project tech stack and generate CLAUDE.md + rules
---

## Project Initialization

Analyze the current project and generate customized `CLAUDE.md` and `.claude/rules/` files.

### Step 1: Detect Tech Stack

Read and analyze the following files (if they exist):

- `package.json` — dependencies, scripts, package manager (check for `packageManager` field, lock files: `pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`)
- `tsconfig.json` / `jsconfig.json` — language, path aliases
- `vite.config.*` / `next.config.*` / `webpack.config.*` / `nuxt.config.*` — build tool
- `tailwind.config.*` / `postcss.config.*` — styling approach
- `.eslintrc.*` / `eslint.config.*` — linting setup
- `.prettierrc*` — formatting
- `vitest.config.*` / `jest.config.*` / `cypress.config.*` — testing framework
- `Dockerfile` / `docker-compose.*` — containerization
- Source directory structure — `src/`, `app/`, `pages/`, `components/`

Identify:
1. **Framework**: React, Vue, Next.js, Nuxt, Svelte, Angular, vanilla, etc.
2. **Build tool**: Vite, Webpack, Turbopack, Rollup, esbuild, etc.
3. **Language**: TypeScript (strict?), JavaScript, etc.
4. **Package manager**: pnpm, npm, yarn, bun
5. **Styling**: Tailwind, CSS Modules, styled-components, Sass, etc.
6. **State management**: Zustand, Redux, Pinia, Jotai, etc.
7. **Routing**: React Router, Next.js file routing, Vue Router, etc.
8. **Testing**: Vitest, Jest, Cypress, Playwright, etc.
9. **Available scripts**: dev, build, test, lint, format, etc.

### Step 2: Generate CLAUDE.md

Replace the skeleton `CLAUDE.md` with a customized version. Include:

- **Project Overview** — brief description based on package.json name/description
- **Quick Commands** — actual scripts from package.json, using the detected package manager
- **Project Structure** — actual directory layout (read `src/` or equivalent)
- **Code Conventions** — inferred from existing config (TSConfig strictness, ESLint rules, etc.)
- **Spec-Driven Development** — OpenSpec section (keep as-is)
- **Design System** — if UI project, mention DESIGN.md; if not, omit
- **Testing** — actual test framework and commands
- **Git Conventions** — keep conventional commits
- **Critical Rules** — adapt to the detected stack

### Step 3: Generate Stack-Specific Rules

Based on detected stack, create appropriate rules in `.claude/rules/`:

- If React/Vue/Svelte → create `frontend-conventions.md` with framework-specific patterns
- If Tailwind → include Tailwind rules in conventions
- If Zustand/Redux/Pinia → create `state-management.md`
- If TypeScript → include type safety rules
- Always keep: `debugging.md`, `git-workflow.md`, `openspec-workflow.md`, `testing-strategy.md`

Update the testing-strategy rule's commands to match the actual test runner.
Update the git-workflow rule's quality gate commands to match actual scripts.
Update the quality-check command to use actual scripts.

### Step 4: Update settings.json

Add package-manager-specific permissions to `.claude/settings.json`:
- Detect the package manager and add `Bash(<pm> *)` to allow list
- Add any project-specific CLI tools found in scripts

### Step 5: Report

Show the user a summary:
- Detected stack (framework, build tool, language, PM, etc.)
- Files generated/updated
- Anything that needs manual attention (e.g., "No test framework detected — consider adding Vitest")
- Suggest running `/design-system init` if it's a UI project without DESIGN.md
