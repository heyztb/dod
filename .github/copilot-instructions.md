This repository is a Bun + Hono + Vite + React monorepo ("bhvr" fork) with three workspaces: `client`, `server`, and `shared`.

Key goals for an AI coding agent working here:
- Keep changes small and workspace-scoped (prefer editing `client/` or `server/` files). Avoid large refactors across `contracts/` unless asked.
- Preserve TypeScript types and shared types in `shared/` — this project relies on path/workspace imports like `shared` and `server/src/client`.

Quick architecture summary (what to know fast):
- `client/` — React + Vite app. Entry: `client/src/main.tsx` and routes under `client/src/routes/` (example: `client/src/routes/index.tsx`).
- `server/` — Hono backend. App is exported from `server/src/index.ts`. Typed Hono client helper lives in `server/src/client.ts` (`hcWithType`).
- `shared/` — Common types exported from `shared/src/index.ts` and `shared/src/types` (used by both client and server).
- Monorepo orchestration via Turbo (see `turbo.json`) and Bun package manager (root `package.json` uses `bun`).
- Deployment target: Cloudflare Worker using `wrangler.jsonc` (main: `server/dist/index.js`, assets: `client/dist`).

Developer workflows and exact commands (use these; they are authoritative):
- Install all workspaces: `bun install`
- Start everything (dev): `bun run dev` (runs `turbo dev` across workspaces)
- Start frontend only: `bun run dev:client` (Vite)
- Start backend only: `bun run dev:server` (Hono/Bun watch + tsc watch)
- Build all: `bun run build` (Turbo build)
- Build and deploy to Cloudflare: `bun run deploy` (runs `turbo build && wrangler deploy --minify`)
- Local server dev script (server workspace): `bun --watch run src/index.ts && tsc --watch` (see `server/package.json` scripts)

Project-specific conventions and gotchas:
- Types & imports: packages use workspace aliases. You'll see imports like `import type { ApiResponse } from "shared/dist"` or `import { hcWithType } from "server/src/client"`. When editing, prefer maintaining the shape of exported types in `shared/src/types` and update `shared` build if changing type exports.
- Hono routing: `server/src/index.ts` registers middleware (CORS, logger, trimTrailingSlash) and uses `.basePath('/api')`. Adjusting API paths must consider `basePath` and client usage (`hcWithType('/')` in `client/src/routes/index.tsx`).
- Auth: quick auth middleware is in `server/src/quickAuthMiddleware.ts` and uses `@farcaster/quick-auth`. If you change auth behavior, update both middleware and any client usages (look for `.get('/me', quickAuthMiddleware, ...)`).
- Build outputs: `server` emits `dist/` (used by wrangler), `client` emits `dist/` (static assets). `turbo` expects `dist/**` outputs (see `turbo.json`). Keep those outputs intact.

Where to look for examples (use these in suggestions):
- API route example: `server/src/index.ts` (hello, me endpoints)
- Auth and external API calls: `server/src/quickAuthMiddleware.ts` (Farcaster primary address lookup)
- Typed Hono client usage: `server/src/client.ts` and `client/src/routes/index.tsx` (see `hcWithType('/')`)
- Vite config + env hint: `client/vite.config.ts` and `client/index.html` (preconnect to Farcaster auth)
- Deployment config: `wrangler.jsonc` (main and assets paths)

Editing guidance for AI:
- Small focused PRs: change one workspace at a time; run `bun run build:shared` or `bun run build:server` when editing shared types or server code.
- Preserve runtime compatibility: `wrangler.jsonc` expects `server/dist/index.js`. If changing server entry, update `wrangler.jsonc` accordingly.
- When adding endpoints, update Hono `basePath` awareness and add TypeScript types to `shared/src/types` for any cross-boundary payloads.
- Prefer using `hcWithType` for client-to-server calls to keep types aligned.

Testing and CI notes (discoverable in repo but follow these):
- Turbo orchestrates test/type-check/lint tasks (`bun run test`, `bun run lint`, `bun run type-check`). Use these scripts in PRs.

If you need clarification, ask: "Which workspace should I change (client/server/shared/contracts)?" or "Should this change be compatible with Cloudflare Worker deployment?" 

Next steps after edits: run `bun run build` and ensure `server/dist` and `client/dist` are produced; run `bun run dev` to smoke-test locally.

If anything here is unclear or you want more examples (e.g., typical Hono handler signature, or how Farcaster auth flows are used in the client), tell me and I'll expand specific sections.
