# CLAUDE.md

## Project Overview

Frontend project template with Claude Code harness. Tech stack: **React + Vite + React Router + Tailwind CSS**.

## Quick Commands

```bash
# Dev
npm run dev          # Start dev server (Vite)
npm run build        # Production build
npm run preview      # Preview production build
npm run lint         # ESLint check
npm run type-check   # TypeScript type check (tsc --noEmit)
npm run test         # Run vitest
npm run test:ui      # Vitest with UI

# Quality gates (run before commit)
npm run lint && npm run type-check && npm run test
```

## Project Structure

```
src/
├── app/              # App shell, providers, router config
│   ├── App.tsx
│   ├── providers.tsx # Context providers composition
│   └── router.tsx    # React Router config
├── components/       # Shared UI components
│   ├── ui/           # Base design system components (Button, Input, etc.)
│   └── layout/       # Layout components (Header, Sidebar, etc.)
├── features/         # Feature modules (domain-driven)
│   └── [feature]/
│       ├── components/
│       ├── hooks/
│       ├── api/
│       ├── types.ts
│       └── index.ts  # Public barrel export
├── hooks/            # Shared custom hooks
├── lib/              # Utilities, helpers, constants
├── styles/           # Global styles, Tailwind config extensions
├── types/            # Shared TypeScript types
└── assets/           # Static assets (images, fonts, icons)
```

## Code Conventions

- **Language**: TypeScript strict mode, no `any`
- **Components**: Function components with named exports, no default exports
- **Styling**: Tailwind utility classes only. Use `cn()` (clsx + twMerge) for conditional classes
- **State**: Zustand for global/shared state, React state for local component state. Use TanStack Query for server state if needed
- **Routing**: React Router v7 file-convention or explicit config in `app/router.tsx`
- **Naming**: PascalCase for components, camelCase for functions/vars, kebab-case for files
- **Imports**: Absolute imports via `@/` alias pointing to `src/`

## Design System

- Components in `src/components/ui/` follow a consistent API pattern
- All colors, spacing, typography defined in `tailwind.config.ts`
- For personal projects: design tokens sourced from getdesign.md
- For client projects: design tokens built from prototypes on top of Tailwind defaults

## Spec-Driven Development (OpenSpec)

This project uses [OpenSpec](https://github.com/Fission-AI/OpenSpec) for structured planning.

**Workflow**: Brainstorm → `/opsx:propose` → `/opsx:apply` → `/opsx:verify` → `/opsx:archive`

- Specs live in `openspec/specs/` (source of truth for current behavior)
- Changes live in `openspec/changes/` (proposals, delta specs, design, tasks)
- Every non-trivial feature goes through OpenSpec propose before coding
- Specs describe behavior (Given/When/Then), NOT implementation

## Testing

- Unit tests: Vitest + React Testing Library
- Test files colocated: `ComponentName.test.tsx` next to the component
- Test naming: `describe('ComponentName')` → `it('should ...')`

## Git Conventions

- Branch: `feat/xxx`, `fix/xxx`, `refactor/xxx`, `chore/xxx`
- Commit: conventional commits (`feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`)
- Separate commits per logical change, not per file

## Critical Rules

- NEVER modify `package-lock.json` manually
- NEVER commit `.env` files or secrets
- Always run quality gates before committing
- Start with plan mode for any feature > 1 component
- Use `/compact` at ~50% context usage
- When debugging, reproduce first → diagnose → fix → verify
