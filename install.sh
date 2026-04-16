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
  echo "Usage: ./install.sh <project-name>"
  echo ""
  echo "Creates a new React + Vite + Tailwind project with Claude Code harness."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$(pwd)/$PROJECT_NAME"

if [ -d "$TARGET_DIR" ]; then
  error "Directory $TARGET_DIR already exists!"
fi

# --- Step 1: Create Vite project ---
log "Creating Vite + React + TypeScript project..."
npm create vite@latest "$PROJECT_NAME" -- --template react-ts
cd "$TARGET_DIR"
success "Vite project created"

# --- Step 2: Install dependencies ---
log "Installing dependencies..."
npm install
npm install react-router-dom zustand
success "Core dependencies installed"

# --- Step 3: Install dev dependencies ---
log "Installing dev dependencies..."
# Install OpenSpec globally if not present
if ! command -v openspec &> /dev/null; then
  log "Installing OpenSpec globally..."
  npm install -g @fission-ai/openspec@latest
  success "OpenSpec installed"
fi

npm install -D tailwindcss @tailwindcss/vite
npm install -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom
npm install -D clsx tailwind-merge
npm install -D prettier prettier-plugin-tailwindcss
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

# --- Step 6: Create project structure ---
log "Creating project structure..."
mkdir -p src/{app,components/{ui,layout},features,hooks,lib,styles,types,assets}
mkdir -p docs/plans

# cn utility
cat > src/lib/cn.ts << 'CN_EOF'
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
CN_EOF

# Test setup
cat > src/test-setup.ts << 'TESTSETUP_EOF'
import "@testing-library/jest-dom/vitest";
TESTSETUP_EOF

# App shell
cat > src/app/App.tsx << 'APP_EOF'
import { RouterProvider } from "react-router-dom";
import { router } from "./router";

export function App() {
  return <RouterProvider router={router} />;
}
APP_EOF

# Router config
cat > src/app/router.tsx << 'ROUTER_EOF'
import { createBrowserRouter } from "react-router-dom";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <div className="p-8 text-center"><h1 className="text-3xl font-bold">Hello World</h1></div>,
  },
]);
ROUTER_EOF

# Example zustand store
mkdir -p src/lib/stores
cat > src/lib/stores/app-store.ts << 'STORE_EOF'
import { create } from "zustand";

interface AppStore {
  theme: "light" | "dark";
  toggleTheme: () => void;
}

export const useAppStore = create<AppStore>()((set) => ({
  theme: "light",
  toggleTheme: () =>
    set((state) => ({ theme: state.theme === "light" ? "dark" : "light" })),
}));
STORE_EOF

# Update main.tsx
cat > src/main.tsx << 'MAIN_EOF'
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { App } from "./app/App";
import "./index.css";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
MAIN_EOF

# Prettier config
cat > .prettierrc << 'PRETTIER_EOF'
{
  "semi": true,
  "singleQuote": false,
  "tabWidth": 2,
  "trailingComma": "all",
  "plugins": ["prettier-plugin-tailwindcss"]
}
PRETTIER_EOF

success "Project structure created"

# --- Step 7: Add npm scripts ---
log "Adding npm scripts..."
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
success "npm scripts added"

# --- Step 8: Copy Claude Code harness ---
log "Setting up Claude Code harness..."

# Copy CLAUDE.md
cp "$SCRIPT_DIR/CLAUDE.md" ./CLAUDE.md

# Copy .claude directory
cp -r "$SCRIPT_DIR/.claude" ./.claude

# Copy .gitignore (merge with existing if present)
if [ -f .gitignore ]; then
  # Append our entries that aren't already present
  while IFS= read -r line; do
    if [ -n "$line" ] && ! grep -qF "$line" .gitignore 2>/dev/null; then
      echo "$line" >> .gitignore
    fi
  done < "$SCRIPT_DIR/.gitignore"
else
  cp "$SCRIPT_DIR/.gitignore" ./.gitignore
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

# --- Done ---
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN} Project '$PROJECT_NAME' created successfully!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo "  cd $PROJECT_NAME"
echo "  npm run dev        # Start dev server"
echo "  claude             # Open Claude Code"
echo ""
echo "  Claude Code commands:"
echo "    /new-feature     # Brainstorm → OpenSpec propose → implement → ship"
echo "    /debug           # Debug a bug systematically"
echo "    /design-system   # Init or extend the design system"
echo "    /quality-check   # Run all quality gates"
echo ""
echo "  OpenSpec commands:"
echo "    /opsx:propose    # Create structured spec + design + tasks"
echo "    /opsx:apply      # Implement from tasks.md"
echo "    /opsx:verify     # Validate implementation vs specs"
echo "    /opsx:archive    # Finalize and archive change"
echo ""
