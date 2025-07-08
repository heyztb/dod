## Build, Lint, and Test

- **Build**: `bun run build`
- **Lint**: `bun run lint`
- **Format**: `bun run format`
- **Type Check**: `bun run check`
- **Solidity Tests**: `forge test`
- **Run a single Solidity test file**: `forge test --match-path test/FarkleGameImpl.t.sol`
- **Run a single Solidity test**: `forge test --match-test testSomething`

## Code Style

### General

- Use Prettier for formatting.
- Follow ESLint rules.

### Svelte 5

- Use `$state` for reactive variables, not `let`.
- Use `$derived` for derived state, not `$:`.
- Use `$effect` for side effects, not `$:`.
- Use `$props` to declare component properties, not `export let`.
- Use `onclick` instead of `on:click`.
- Use callback props instead of `createEventDispatcher`.
- Use snippets (`{#snippet ...}`) instead of slots.

### SvelteKit 2

- Call `error()` and `redirect()` directly, don't `throw` them.
- Always provide a `path` when setting cookies.
- `await` top-level promises in `load` functions.
- Use `$app/state` instead of the deprecated `$app/stores`.

### Tailwind CSS 4

- Configure in CSS with `@theme`, not `tailwind.config.js`.
- Use `@import "tailwindcss";` instead of `@tailwind` directives.
- Use CSS variables (e.g., `var(--color-blue-500)`) for theme values.
- Use composable variants (e.g., `group-has-data-potato:opacity-100`).
