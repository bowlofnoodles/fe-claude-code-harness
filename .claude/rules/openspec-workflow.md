<important if="planning features, writing specs, creating proposals, or starting new work">

## OpenSpec Workflow Rules

This project uses OpenSpec for structured spec-driven development.

### Directory Structure
```
openspec/
├── specs/              # Source of truth — current system behavior
│   └── [domain]/       # Organized by domain (auth/, ui/, etc.)
└── changes/            # Proposed modifications
    ├── [change-name]/
    │   ├── proposal.md # Intent, scope, rationale
    │   ├── specs/      # Delta specs (ADDED/MODIFIED/REMOVED)
    │   ├── design.md   # Technical approach
    │   └── tasks.md    # Implementation checklist
    └── archive/        # Completed changes with date prefix
```

### Core Commands
- `/opsx:propose <description>` — Create change with all planning artifacts
- `/opsx:apply` — Implement tasks from a change
- `/opsx:verify` — Validate implementation matches specs
- `/opsx:archive` — Finalize and archive completed change

### Rules
- Every non-trivial feature MUST go through `/opsx:propose` before implementation
- Specs describe observable BEHAVIOR, not implementation details
- Use RFC 2119 keywords: MUST, SHALL, SHOULD, MAY for requirement strength
- Scenarios use Given/When/Then format
- design.md contains technical decisions; specs do NOT
- After archiving, delta specs merge into main specs — this is the living documentation

### When to Skip OpenSpec
- Bug fixes (use `/debug` command instead)
- Trivial changes (< 10 lines, single file)
- Config-only changes

</important>
