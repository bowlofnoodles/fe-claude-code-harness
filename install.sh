#!/bin/bash
set -euo pipefail

# ============================================================
# Frontend Project Initializer with Claude Code Harness
# Stack: React + Vite + TypeScript + React Router + Tailwind CSS
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

# --- Args ---
PROJECT_NAME="${1:-}"
if [ -z "$PROJECT_NAME" ]; then
  echo ""
  echo "Usage:"
  echo "  ./install.sh <project-name>"
  echo "  curl -fsSL https://raw.githubusercontent.com/bowlofnoodles/fe-claude-code-harness/main/install.sh | bash -s -- <project-name>"
  echo ""
  echo "Creates a new React + Vite + Tailwind project with Claude Code harness."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
TARGET_DIR="$(pwd)/$PROJECT_NAME"

# Detect if running via curl pipe (no local repo available)
is_remote() {
  [ ! -f "$SCRIPT_DIR/CLAUDE.md" ] 2>/dev/null
}

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
# Install OpenSpec globally if not present
if ! command -v openspec &> /dev/null; then
  log "Installing OpenSpec globally..."
  npm install -g @fission-ai/openspec@latest
  success "OpenSpec installed"
fi

pnpm add -D tailwindcss @tailwindcss/vite
pnpm add -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom
pnpm add -D clsx tailwind-merge
pnpm add -D prettier prettier-plugin-tailwindcss
success "Dev dependencies installed"

# --- Step 4: Configure Tailwind ---
log "Configuring Tailwind CSS..."

# Create tailwind config
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

# Update main CSS
cat > src/index.css << 'CSS_EOF'
@import "tailwindcss";
CSS_EOF

# Update vite config for Tailwind
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

# cn utility — always needed for Tailwind class composition
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
# Use node to update package.json scripts
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

REPO_URL="https://github.com/bowlofnoodles/fe-claude-code-harness.git"

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

if is_remote; then
  # Remote mode — clone to tmp, copy harness files, clean up
  HARNESS_TMP=$(mktemp -d)
  log "Cloning harness repo to temp directory..."
  git clone --depth 1 "$REPO_URL" "$HARNESS_TMP" 2>/dev/null

  cp "$HARNESS_TMP/CLAUDE.md" ./CLAUDE.md
  cp -r "$HARNESS_TMP/.claude" ./.claude
  merge_gitignore "$HARNESS_TMP/.gitignore"

  # Clean up
  rm -rf "$HARNESS_TMP"
else
  # Local mode — copy from cloned repo
  cp "$SCRIPT_DIR/CLAUDE.md" ./CLAUDE.md
  cp -r "$SCRIPT_DIR/.claude" ./.claude
  merge_gitignore "$SCRIPT_DIR/.gitignore"
fi

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
log "Installing Superpowers skill..."

# Superpowers is a Claude Code plugin, installed via the claude CLI
# Try the official marketplace first, fallback to alternative
if command -v claude &> /dev/null; then
  # Use --yes to auto-confirm, run in project directory
  claude -p "Run /plugin install superpowers@claude-plugins-official" --yes 2>/dev/null \
    || claude -p "/plugin marketplace add obra/superpowers-marketplace && /plugin install superpowers@superpowers-marketplace" --yes 2>/dev/null \
    || warn "Auto-install failed. Install manually in Claude Code (see below)"
  success "Superpowers plugin installed"
else
  warn "Claude CLI not found. Install Superpowers manually after setup."
fi

# --- Done ---
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN} Project '$PROJECT_NAME' created successfully!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "  cd $PROJECT_NAME"
echo "  pnpm dev           # Start dev server"
echo "  claude             # Open Claude Code"
echo ""
echo -e "  ${YELLOW}[!] If Superpowers didn't auto-install, run this in Claude Code:${NC}"
echo "    /plugin install superpowers@claude-plugins-official"
echo ""
echo -e "  ${CYAN}Claude Code commands:${NC}"
echo -e "    ${GREEN}/new-feature${NC}      # Brainstorm → OpenSpec propose → implement → ship"
echo -e "    ${GREEN}/debug${NC}            # Debug a bug systematically"
echo -e "    ${GREEN}/design-system${NC}    # Init or extend the design system"
echo -e "    ${GREEN}/clarify-business${NC} # Document business domain knowledge"
echo -e "    ${GREEN}/quality-check${NC}    # Run all quality gates"
echo ""
echo -e "  ${CYAN}OpenSpec commands:${NC}"
echo -e "    ${GREEN}/opsx:propose${NC}     # Create structured spec + design + tasks"
echo -e "    ${GREEN}/opsx:apply${NC}       # Implement from tasks.md"
echo -e "    ${GREEN}/opsx:verify${NC}      # Validate implementation vs specs"
echo -e "    ${GREEN}/opsx:archive${NC}     # Finalize and archive change"
echo ""
