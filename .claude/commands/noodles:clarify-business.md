---
description: Clarify and document business domain knowledge through interactive Q&A
argument-hint: [domain or topic, e.g. "user permissions" or "order flow"]
---

## Business Knowledge Clarification

Topic: **$ARGUMENTS**

This command helps you document business domain knowledge so Claude understands your project's context in future conversations.

### Step 1: Interview

Ask the user targeted questions to understand the business domain. Focus on:

- **Terminology**: What do domain-specific terms mean? (e.g. "tenant", "workspace", "campaign")
- **Business rules**: What are the invariants? (e.g. "an order cannot be cancelled after shipping")
- **User roles & permissions**: Who can do what?
- **Data relationships**: How do core entities relate?
- **Edge cases**: What are the known tricky scenarios?
- **External constraints**: Compliance, legal, third-party API limitations

Ask one topic at a time. Confirm understanding before moving on.

### Step 2: Classify and Write

After gathering enough context, organize the knowledge into two tiers:

**Tier 1 — Core rules** → Write to `.claude/rules/business-context.md`
These are concise rules that Claude should ALWAYS know while coding. Format:

```markdown
<important if="working on [relevant domain]">

## [Domain] Business Rules

- Rule 1: ...
- Rule 2: ...
- Terminology: "X" means ...

</important>
```

Keep this file under 100 lines total. If a domain grows too large, split into a separate rule file like `.claude/rules/business-[domain].md`.

**Tier 2 — Detailed docs** → Write to `docs/business/[domain].md`
These are comprehensive reference documents that Claude reads on demand. Include:
- Full entity descriptions and relationships
- Detailed workflow/process documentation
- Decision trees and edge case handling
- Historical context and rationale

### Step 3: Confirm

Show the user what was written and where:
- "Core rules added to `.claude/rules/business-context.md` — Claude will see these automatically"
- "Detailed docs saved to `docs/business/[domain].md` — Claude will read these when working on [domain]"

Ask if anything needs adjustment.

### Step 4: Update CLAUDE.md (if needed)

If this is the first time adding business docs, append a section to CLAUDE.md:

```markdown
## Business Context

Core business rules are in `.claude/rules/business-context.md` (auto-loaded).
Detailed domain docs are in `docs/business/` (read on demand when working on that domain).
```
