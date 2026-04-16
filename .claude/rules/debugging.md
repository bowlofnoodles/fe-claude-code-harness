<important if="debugging, fixing bugs, or investigating errors">

## Debugging Protocol

1. **Reproduce**: Confirm the bug exists and can be triggered consistently
2. **Isolate**: Narrow down to the smallest failing case
3. **Diagnose**: Read error messages, stack traces, and relevant code. Form a hypothesis
4. **Fix**: Make the minimal change that addresses the root cause
5. **Verify**: Run the repro steps again + run related tests
6. **Regression check**: Ensure no existing tests break

### Common Frontend Debug Patterns
- **White screen**: Check console for errors, verify router config, check lazy loading boundaries
- **Style not applying**: Check Tailwind class purging, specificity conflicts, cn() ordering
- **State not updating**: Verify immutability, check dependency arrays in useEffect/useMemo
- **API issues**: Check network tab, CORS, request/response shape mismatches
- **Build errors**: Check tsconfig paths, vite.config resolve aliases, missing deps

### Never Do
- Don't guess-and-check randomly — form a hypothesis first
- Don't suppress errors with try/catch unless you handle the error meaningfully
- Don't add `// @ts-ignore` — fix the type error

</important>
