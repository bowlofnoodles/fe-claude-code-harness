<important if="managing state, creating stores, or working with zustand">

## State Management with Zustand

### When to use what
- **React useState**: Local component state only (form inputs, toggles, UI-only state)
- **Zustand store**: Shared/global state (user session, theme, feature-specific shared state)
- **TanStack Query**: Server state (API data, caching, optimistic updates) — add only when needed

### Zustand Conventions
- One store per feature/domain in `src/features/[feature]/store.ts`
- Shared stores in `src/lib/stores/`
- Use slices pattern for large stores
- Always type the store interface explicitly

```tsx
// Pattern: typed store with actions
interface AuthStore {
  user: User | null
  isLoading: boolean
  login: (credentials: Credentials) => Promise<void>
  logout: () => void
}

export const useAuthStore = create<AuthStore>()((set) => ({
  user: null,
  isLoading: false,
  login: async (credentials) => {
    set({ isLoading: true })
    const user = await authApi.login(credentials)
    set({ user, isLoading: false })
  },
  logout: () => set({ user: null }),
}))
```

### Rules
- Use selectors to prevent unnecessary re-renders: `useAuthStore((s) => s.user)`
- Never access store state outside React with `getState()` unless in event handlers or non-React code
- Keep actions inside the store, not in components
- No `immer` middleware unless dealing with deeply nested state

</important>
