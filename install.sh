#!/bin/bash
set -euo pipefail

# ============================================================
# Fe Claude Code Harness Installer
#
# Two modes:
#   ./install.sh <project-name>    Create new React+Vite+Tailwind project
#   ./install.sh --inject          Inject harness into existing project
# ============================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${CYAN}[harness]${NC} $1"; }
success() { echo -e "${GREEN}[done]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
REPO_URL="https://github.com/bowlofnoodles/fe-claude-code-harness.git"

# Detect if running via curl pipe (no local repo available)
is_remote() {
  [ ! -f "$SCRIPT_DIR/CLAUDE.md" ] 2>/dev/null
}

# Helper: merge .gitignore entries
merge_gitignore() {
  local source="$1"
  if [ -f .gitignore ]; then
    while IFS= read -r line; do
      if [ -n "$line" ] && ! grep -qF "$line" .gitignore 2>/dev/null; then
        echo "$line" >> .gitignore
      fi
    done < "$source"
  else
    cp "$source" ./.gitignore
  fi
}

# Helper: get harness source directory (local or clone to tmp)
get_harness_dir() {
  if is_remote; then
    HARNESS_TMP=$(mktemp -d)
    log "Cloning harness repo to temp directory..." >&2
    git clone --depth 1 "$REPO_URL" "$HARNESS_TMP" 2>/dev/null
    echo "$HARNESS_TMP"
  else
    echo "$SCRIPT_DIR"
  fi
}

# Helper: cleanup tmp if needed
cleanup_harness_tmp() {
  if [ -n "${HARNESS_TMP:-}" ] && [ -d "${HARNESS_TMP:-}" ]; then
    rm -rf "$HARNESS_TMP"
  fi
}

# Helper: install OpenSpec globally
install_openspec() {
  if ! command -v openspec &> /dev/null; then
    log "Installing OpenSpec globally..."
    npm install -g @fission-ai/openspec@latest
    success "OpenSpec installed"
  fi
}

# Helper: install Superpowers plugin
install_superpowers() {
  log "Installing Superpowers skill..."
  if command -v claude &> /dev/null; then
    claude -p "Run /plugin install superpowers@claude-plugins-official" --yes 2>/dev/null \
      || claude -p "/plugin marketplace add obra/superpowers-marketplace && /plugin install superpowers@superpowers-marketplace" --yes 2>/dev/null \
      || warn "Auto-install failed. Install manually in Claude Code (see below)"
    success "Superpowers plugin installed"
  else
    warn "Claude CLI not found. Install Superpowers manually after setup."
  fi
}

# Helper: print commands summary
print_commands() {
  echo ""
  echo -e "  ${YELLOW}[!] If Superpowers didn't auto-install, run this in Claude Code:${NC}"
  echo "    /plugin install superpowers@claude-plugins-official"
  echo ""
  echo -e "  ${CYAN}Claude Code commands (with 'noodles:' prefix):${NC}"
  echo -e "    ${GREEN}/noodles:init-project${NC}     # Auto-detect stack and generate CLAUDE.md + rules"
  echo -e "    ${GREEN}/noodles:new-feature${NC}      # Brainstorm → OpenSpec propose → implement → ship"
  echo -e "    ${GREEN}/noodles:debug${NC}            # Debug a bug systematically"
  echo -e "    ${GREEN}/noodles:design-system${NC}    # Init or extend the design system"
  echo -e "    ${GREEN}/noodles:clarify-business${NC} # Document business domain knowledge"
  echo -e "    ${GREEN}/noodles:quality-check${NC}    # Run all quality gates"
  echo ""
  echo -e "  ${CYAN}OpenSpec commands (no prefix):${NC}"
  echo -e "    ${GREEN}/opsx:propose${NC}     # Create structured spec + design + tasks"
  echo -e "    ${GREEN}/opsx:apply${NC}       # Implement from tasks.md"
  echo -e "    ${GREEN}/opsx:verify${NC}      # Validate implementation vs specs"
  echo -e "    ${GREEN}/opsx:archive${NC}     # Finalize and archive change"
  echo ""
  echo -e "  ${YELLOW}📖 See HARNESS_USAGE.md for complete usage guide${NC}"
  echo ""
}

# ============================================================
# MODE: --inject (existing project)
# ============================================================
run_inject() {
  local FRONTEND_DIR="${1:-.}"

  log "Injecting Claude Code harness into existing project..."

  # Normalize the frontend directory path
  FRONTEND_DIR=$(realpath "$FRONTEND_DIR" 2>/dev/null || echo "$FRONTEND_DIR")

  if [ "$FRONTEND_DIR" != "." ] && [ "$FRONTEND_DIR" != "$(pwd)" ]; then
    log "Frontend directory specified: $FRONTEND_DIR"
  fi

  # Verify we're in a git repository root
  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    warn "Not in a git repository. The harness should be injected at the repository root."
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
  fi

  # Verify frontend directory exists and has project files
  if [ ! -d "$FRONTEND_DIR" ]; then
    error "Frontend directory '$FRONTEND_DIR' does not exist"
  fi

  if [ ! -f "$FRONTEND_DIR/package.json" ] && [ ! -f "$FRONTEND_DIR/Cargo.toml" ] && [ ! -f "$FRONTEND_DIR/go.mod" ] && [ ! -f "$FRONTEND_DIR/pyproject.toml" ] && [ ! -f "$FRONTEND_DIR/Makefile" ]; then
    warn "No package.json or project manifest found in $FRONTEND_DIR. Are you sure this is the correct directory?"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
  fi

  # Check for existing .claude directory
  if [ -d ".claude" ]; then
    warn "Existing .claude/ directory found."
    read -p "Overwrite? (existing settings.local.json will be preserved) [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
    # Preserve local settings
    if [ -f ".claude/settings.local.json" ]; then
      cp ".claude/settings.local.json" "/tmp/_harness_settings_local_backup.json"
    fi
  fi

  local HARNESS_SRC
  HARNESS_SRC=$(get_harness_dir)

  # --- Copy .claude directory (universal parts only) ---
  log "Copying harness configuration..."
  mkdir -p .claude/{agents,commands,rules,skills,hooks/scripts}

  # Commands — all are universal
  cp "$HARNESS_SRC/.claude/commands/noodles:new-feature.md"      .claude/commands/
  cp "$HARNESS_SRC/.claude/commands/noodles:debug.md"             .claude/commands/
  cp "$HARNESS_SRC/.claude/commands/noodles:design-system.md"     .claude/commands/
  cp "$HARNESS_SRC/.claude/commands/noodles:clarify-business.md"  .claude/commands/
  cp "$HARNESS_SRC/.claude/commands/noodles:quality-check.md"     .claude/commands/

  # Agents — universal
  cp "$HARNESS_SRC/.claude/agents/component-builder.md"   .claude/agents/
  cp "$HARNESS_SRC/.claude/agents/feature-reviewer.md"    .claude/agents/

  # Rules — universal (not tech-stack-specific)
  cp "$HARNESS_SRC/.claude/rules/openspec-workflow.md"    .claude/rules/
  cp "$HARNESS_SRC/.claude/rules/debugging.md"            .claude/rules/
  cp "$HARNESS_SRC/.claude/rules/git-workflow.md"         .claude/rules/
  cp "$HARNESS_SRC/.claude/rules/testing-strategy.md"     .claude/rules/

  # Settings — use a minimal universal version for inject mode
  if [ ! -f ".claude/settings.json" ]; then
    # Calculate relative path from repo root to frontend directory
    local REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local REL_FRONTEND_DIR=$(python3 -c "import os.path; print(os.path.relpath('$FRONTEND_DIR', '$REPO_ROOT'))" 2>/dev/null || echo ".")

    cat > .claude/settings.json << SETTINGS_EOF
{
  "permissions": {
    "allow": [
      "Edit(*)",
      "Write(*)",
      "Bash(git *)",
      "Bash(gh *)",
      "Bash(ls *)",
      "Bash(mkdir *)",
      "Bash(which *)",
      "WebFetch(domain:github.com)",
      "WebSearch"
    ],
    "deny": [],
    "ask": []
  },
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "70",
    "FRONTEND_DIR": "$REL_FRONTEND_DIR"
  },
  "plansDirectory": "./docs/plans",
  "respectGitignore": true
}
SETTINGS_EOF
    success "Created minimal settings.json (run /noodles:init-project to customize)"
    if [ "$REL_FRONTEND_DIR" != "." ]; then
      log "Frontend directory set to: $REL_FRONTEND_DIR"
    fi
  else
    warn "Existing settings.json preserved"
  fi

  # Restore local settings if backed up
  if [ -f "/tmp/_harness_settings_local_backup.json" ]; then
    mv "/tmp/_harness_settings_local_backup.json" ".claude/settings.local.json"
  fi

  # .gitignore — merge harness entries
  merge_gitignore "$HARNESS_SRC/.gitignore"

  # Create docs directories
  mkdir -p docs/{plans,business}

  # Copy usage documentation
  cp "$HARNESS_SRC/HARNESS_USAGE.md" ./HARNESS_USAGE.md

  # Copy noodles:init-project command (critical for inject mode)
  # This is already in the commands we copied above

  # DON'T copy CLAUDE.md — it's tech-stack-specific
  # Instead create a skeleton that /noodles:init-project will fill
  if [ ! -f "CLAUDE.md" ]; then
    local FRONTEND_NOTE=""
    if [ "$REL_FRONTEND_DIR" != "." ]; then
      FRONTEND_NOTE="\n\n> **Note**: Frontend code is in \`$REL_FRONTEND_DIR/\` directory."
    fi

    cat > CLAUDE.md << SKELETON_EOF
# CLAUDE.md

> This file was auto-generated by harness inject. Run \`/noodles:init-project\` in Claude Code to auto-detect your tech stack and fill in project-specific details.$FRONTEND_NOTE

## Project Overview

<!-- /noodles:init-project will fill this -->

## Quick Commands

<!-- /noodles:init-project will detect your package manager and scripts -->

\`\`\`bash
# TODO: run /noodles:init-project to populate
\`\`\`

## Code Conventions

<!-- /noodles:init-project will analyze your codebase and fill this -->

## Spec-Driven Development (OpenSpec)

This project uses [OpenSpec](https://github.com/Fission-AI/OpenSpec) for structured planning.

**Workflow**: Brainstorm → \`/opsx:propose\` → \`/opsx:apply\` → \`/opsx:verify\` → \`/opsx:archive\`

- Specs live in \`openspec/specs/\` (source of truth for current behavior)
- Changes live in \`openspec/changes/\` (proposals, delta specs, design, tasks)
- Every non-trivial feature goes through OpenSpec propose before coding
- Specs describe behavior (Given/When/Then), NOT implementation

## Design System

- Design spec is documented in \`DESIGN.md\` at project root (generated via \`/design-system init\`)
- **Before writing any UI component, read \`DESIGN.md\` first**

## Git Conventions

- Branch: \`feat/xxx\`, \`fix/xxx\`, \`refactor/xxx\`, \`chore/xxx\`
- Commit: conventional commits
- Separate commits per logical change

## Critical Rules

- NEVER commit \`.env\` files or secrets
- Start with plan mode for any feature > 1 component
- Use \`/compact\` at ~50% context usage
- When debugging, reproduce first → diagnose → fix → verify
SKELETON_EOF
    success "Created skeleton CLAUDE.md (run /noodles:init-project to customize)"
  else
    warn "Existing CLAUDE.md preserved"
  fi

  cleanup_harness_tmp

  success "Claude Code harness injected"

  # --- Install OpenSpec + Superpowers ---
  install_openspec

  log "Initializing OpenSpec..."
  openspec init 2>/dev/null || warn "OpenSpec init skipped (run 'openspec init' manually if needed)"

  install_superpowers

  # --- Done ---
  echo ""
  echo -e "${GREEN}============================================================${NC}"
  echo -e "${GREEN} Harness injected successfully!${NC}"
  echo -e "${GREEN}============================================================${NC}"
  echo ""
  echo "  Next steps:"
  echo -e "    1. ${GREEN}claude${NC}                # Open Claude Code"
  echo -e "    2. ${GREEN}/noodles:init-project${NC} # Auto-detect stack, generate CLAUDE.md + rules"
  echo ""
  echo -e "  📖 ${CYAN}Read HARNESS_USAGE.md for complete command reference and workflows${NC}"
  echo ""
  print_commands
}

# ============================================================
# MODE: new project (default)
# ============================================================
run_new_project() {
  local PROJECT_NAME="$1"
  local TARGET_DIR="$(pwd)/$PROJECT_NAME"

  if [ -d "$TARGET_DIR" ]; then
    error "Directory $TARGET_DIR already exists!"
  fi

  # --- Step 1: Create Vite project ---
  log "Creating Vite + React + TypeScript project..."
  pnpm create vite "$PROJECT_NAME" --template react-ts
  cd "$TARGET_DIR"
  success "Vite project created"

  # --- Step 2: Install dependencies ---
  log "Installing dependencies..."
  pnpm install
  pnpm add react-router-dom zustand
  success "Core dependencies installed"

  # --- Step 3: Install dev dependencies ---
  log "Installing dev dependencies..."
  install_openspec

  pnpm add -D tailwindcss @tailwindcss/vite
  pnpm add -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom
  pnpm add -D clsx tailwind-merge
  pnpm add -D prettier prettier-plugin-tailwindcss
  success "Dev dependencies installed"

  # --- Step 4: Configure Tailwind ---
  log "Configuring Tailwind CSS..."

  cat > tailwind.config.ts << 'TAILWIND_EOF'
import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      // Design tokens — customize per project
      // For personal projects: populate from getdesign.md
      // For client projects: extract from prototype
    },
  },
  plugins: [],
};

export default config;
TAILWIND_EOF

  cat > src/index.css << 'CSS_EOF'
@import "tailwindcss";
CSS_EOF

  cat > vite.config.ts << 'VITE_EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./src/test-setup.ts"],
  },
});
VITE_EOF

  success "Tailwind CSS configured"

  # --- Step 5: Configure TypeScript path aliases ---
  log "Configuring TypeScript..."
  cat > tsconfig.json << 'TSCONFIG_EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src", "vite-env.d.ts"]
}
TSCONFIG_EOF

  success "TypeScript configured"

  # --- Step 6: Create project directories ---
  log "Creating project directories..."
  mkdir -p src/{app,components/{ui,layout},features,hooks,lib/stores,styles,types,assets}
  mkdir -p docs/{plans,business}

  cat > src/lib/cn.ts << 'CN_EOF'
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
CN_EOF

  success "Project directories created"

  # --- Step 7: Add scripts ---
  log "Adding scripts..."
  node -e "
const pkg = require('./package.json');
pkg.scripts = {
  ...pkg.scripts,
  'dev': 'vite',
  'build': 'tsc -b && vite build',
  'preview': 'vite preview',
  'lint': 'eslint .',
  'type-check': 'tsc --noEmit',
  'test': 'vitest run',
  'test:watch': 'vitest',
  'test:ui': 'vitest --ui',
  'format': 'prettier --write \"src/**/*.{ts,tsx,css}\"'
};
require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"
  success "Scripts added"

  # --- Step 8: Set up Claude Code harness ---
  log "Setting up Claude Code harness..."

  local HARNESS_SRC
  HARNESS_SRC=$(get_harness_dir)

  cp "$HARNESS_SRC/CLAUDE.md" ./CLAUDE.md
  cp "$HARNESS_SRC/HARNESS_USAGE.md" ./HARNESS_USAGE.md
  cp -r "$HARNESS_SRC/.claude" ./.claude
  merge_gitignore "$HARNESS_SRC/.gitignore"

  cleanup_harness_tmp

  success "Claude Code harness installed"

  # --- Step 8.5: Initialize OpenSpec ---
  log "Initializing OpenSpec..."
  openspec init 2>/dev/null || warn "OpenSpec init skipped (run 'openspec init' manually if needed)"
  success "OpenSpec initialized"

  # --- Step 9: Git init ---
  log "Initializing git..."
  git init
  git add -A
  git commit -m "feat: initial project setup with Claude Code harness

Stack: React + Vite + TypeScript + React Router + Tailwind CSS
Includes: Claude Code harness (.claude/, CLAUDE.md) with commands, agents, and rules

Co-Authored-By: Claude <noreply@anthropic.com>"
  success "Git initialized with initial commit"

  # --- Step 10: Install Superpowers plugin ---
  install_superpowers

  # --- Done ---
  echo ""
  echo -e "${GREEN}============================================================${NC}"
  echo -e "${GREEN} Project '$PROJECT_NAME' created successfully!${NC}"
  echo -e "${GREEN}============================================================${NC}"
  echo ""
  echo "  cd $PROJECT_NAME"
  echo "  pnpm dev           # Start dev server"
  echo "  claude             # Open Claude Code"
  print_commands
}

# ============================================================
# Entry point
# ============================================================
case "${1:-}" in
  --inject)
    run_inject "${2:-.}"
    ;;
  --help|-h|"")
    echo ""
    echo "Fe Claude Code Harness Installer"
    echo ""
    echo -e "  ${CYAN}Usage:${NC}"
    echo -e "    ${GREEN}./install.sh <project-name>${NC}              Create new React+Vite+Tailwind project with harness"
    echo -e "    ${GREEN}./install.sh --inject [frontend-dir]${NC}    Inject harness into existing project (any stack)"
    echo ""
    echo -e "  ${CYAN}Examples:${NC}"
    echo -e "    ${GREEN}./install.sh my-app${NC}                     Create new project"
    echo -e "    ${GREEN}./install.sh --inject${NC}                   Inject into current directory"
    echo -e "    ${GREEN}./install.sh --inject fe${NC}                Inject with frontend code in fe/ subdirectory"
    echo -e "    ${GREEN}./install.sh --inject ./frontend${NC}        Inject with frontend code in frontend/ subdirectory"
    echo ""
    echo -e "  ${CYAN}Remote usage:${NC}"
    echo "    curl -fsSL https://raw.githubusercontent.com/bowlofnoodles/fe-claude-code-harness/main/install.sh | bash -s -- <project-name>"
    echo "    curl -fsSL https://raw.githubusercontent.com/bowlofnoodles/fe-claude-code-harness/main/install.sh | bash -s -- --inject"
    echo "    curl -fsSL https://raw.githubusercontent.com/bowlofnoodles/fe-claude-code-harness/main/install.sh | bash -s -- --inject fe"
    echo ""
    ;;
  *)
    run_new_project "$1"
    ;;
esac
