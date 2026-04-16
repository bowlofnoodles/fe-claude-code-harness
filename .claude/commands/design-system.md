---
description: Set up or extend the design system (tokens, base components)
argument-hint: [component-name or "init"]
---

## Design System Workflow

Target: **$ARGUMENTS**

### If "init" — Initialize Design System
1. Ask the user: personal project (getdesign.md) or client project (prototype-based)?
2. For personal projects:
   - Fetch design spec from getdesign.md
   - Extract colors, typography, spacing, border-radius, shadows
   - Map to `tailwind.config.ts` theme extensions
3. For client projects:
   - Ask for the prototype/mockup
   - Extract design tokens manually from the prototype
   - Map to `tailwind.config.ts` theme extensions
4. Create base components in `src/components/ui/`: Button, Input, Select, Card, Badge, Modal, etc.
5. Create `src/lib/cn.ts` with clsx + tailwind-merge utility

### If component name — Add/Extend Component
1. Check existing components in `src/components/ui/`
2. Follow the established API pattern (variant + size props)
3. Write tests for the component
4. Add to any existing component index/barrel exports
