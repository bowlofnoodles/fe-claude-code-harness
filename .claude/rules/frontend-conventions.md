<important if="writing React components or modifying UI code">

## React & Tailwind Conventions

- Use function components with TypeScript, always with explicit prop types
- Named exports only, no default exports
- Use `cn()` utility (clsx + tailwind-merge) for conditional class composition
- Component file structure: types → component → helpers (in that order)
- Keep components under 150 lines; extract sub-components if larger
- Use `@/` path alias for all imports from `src/`

### Tailwind Rules
- No inline styles — Tailwind utility classes only
- Use design tokens from `tailwind.config.ts` — no arbitrary values like `text-[13px]` unless truly one-off
- Responsive: mobile-first (`sm:`, `md:`, `lg:`)
- Dark mode: use `dark:` variant if the project supports it

### Component API Pattern
```tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  children: React.ReactNode
}

export function Button({ variant = 'primary', size = 'md', children }: ButtonProps) {
  return <button className={cn(baseStyles, variantStyles[variant], sizeStyles[size])}>{children}</button>
}
```

</important>
