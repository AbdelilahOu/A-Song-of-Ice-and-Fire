# CLAUDE.md

Guidance for working in this repository. This file is the source of truth for the
project's intent and conventions. Keep it updated as the project evolves.

## Project management (Linear)

**Tasks, requirements, and the roadmap for this project live in Linear**, not in
this repo. When details are needed for a feature — or when picking up the next
piece of work — refer to the Linear project and its issues, and keep them updated
as work progresses.

- **Linear project:** "Westeros Lineages — GoT Family Tree Explorer" (team
  `Personal`, issue prefix `PER2`).
- Use the `linear-personal` MCP to read/update issues.
- The roadmap is organized into milestones M1–M6: Foundation & Landing, Data
  Model & API, Family Tree Canvas, House & Member Detail, Map of Westeros, and
  Auth-gated Extras. Each milestone holds the concrete issues to work through.
- Mark issues Done as they are completed; open a new issue for any newly
  discovered work rather than tracking it only in code or chat.
- **DB schema reference (Linear doc):** the data model is documented in the
  Linear document "Database Schema — Data Model Reference" in this project
  (https://linear.app/ir7aln/document/database-schema-data-model-reference-255db15ada30).
  **Any time the DB schema changes** (new table, column, enum, or relation), the
  Linear document MUST be updated in the same change to stay the source of truth.

## What this project is

An interactive **Game of Thrones / House of the Dragon family-tree explorer**. It is
a personal side project whose goal is to help the author understand the ASOIAF /
Westeros chronology and the relationships between the Great Houses, in a visual way.

It is NOT a production product. Prioritize clarity, a good visual experience, and
learning value over feature completeness.

### Product vision

- **Landing page** — a single, simple hero section. No heavy content. The entire
  visual identity follows a **House Stark** theme (cold, austere, Winterfell in
  winter: near-black backgrounds, layered greys, with cold silver / frost /
  muted ice-blue accents instead of red and gold; serif/medieval-style display
  font for headings). It should feel cinematic but stay minimal.
- **Family-tree canvas** — the core feature, reachable **without logging in**. A
  large pannable/zoomable canvas ("like a Canva") showing the Great Houses, their
  members, and the connections between them (parent → child, marriages, etc.).
- **Member detail panel** — clicking a member opens a **dialog on the right side**
  of the screen showing that person's info (house, titles, parents, spouse,
  children, short bio, status).
- **Auth-gated features** — some features sit behind login (Better-Auth is already
  wired). The public canvas stays open; logged-in-only extras come later (ideas:
  saving favorite members, personal notes, custom highlight paths). Keep the public
  view fully usable without an account.

### Scope guardrails

- The nine Great Houses are the backbone: Stark, Lannister, Targaryen, Baratheon,
  Tully, Arryn, Tyrell, Martell, Greyjoy. Start with these before any minor houses.
- House sigils/banners and per-house portrait frames are stored in R2 and served
  through the Worker asset proxy. Use `/assets/houses/<house>/banner.webp` and
  `/assets/houses/<house>/frame.webp`; do not add large generated images under
  `apps/web/static/`.

## Tech stack

Scaffolded with [Better-T-Stack](https://github.com/AmanVarshney01/create-better-t-stack).

- **Monorepo:** Turborepo + npm workspaces (`apps/*`, `packages/*`)
- **Frontend:** SvelteKit + TailwindCSS v4 (`@import "tailwindcss"` in `app.css`)
- **Backend:** Hono (runs on Cloudflare Workers)
- **API:** oRPC (end-to-end type-safe); client via `@tanstack/svelte-query`
- **DB:** Drizzle ORM on Cloudflare D1 (SQLite)
- **Auth:** Better-Auth
- **Infra:** Alchemy (`packages/infra`) provisions D1 + deploys to Cloudflare
- **Tooling:** Oxlint (lint) + Oxfmt (format), TypeScript

## Repository layout

```
apps/
  web/      SvelteKit frontend
    src/routes/          +page.svelte (landing), dashboard/, login/
    src/components/       Header, SignInForm, SignUpForm, UserMenu
    src/lib/              auth-client.ts, orpc.ts (client wiring)
  server/   Hono API entry (Cloudflare Worker)
packages/
  api/      oRPC routers + context (packages/api/src/routers/index.ts = appRouter)
  auth/     Better-Auth configuration
  db/       Drizzle schema (packages/db/src/schema/) + migrations
  env/      Shared env/zod validation
  config/   Shared lint/format/ts config
  infra/    Alchemy deployment (alchemy.run.ts, D1 binding "DB")
```

## Commands

```bash
npm install            # install deps
npm run dev            # run everything (web :5173, server :3000)
npm run dev:web        # web only
npm run dev:server     # server only
npm run db:generate    # generate Drizzle migrations after schema changes
npm run check-types    # typecheck all workspaces
npm run check          # oxlint + oxfmt --write
npm run deploy         # deploy to Cloudflare via Alchemy
```

## Conventions

- **No icons or emojis in generated code.** Keep code clean and professional.
- Run `npm run check` before considering work done; keep types passing
  (`npm run check-types`).
- **Adding data models:** edit `packages/db/src/schema/`, export from
  `schema/index.ts`, then `npm run db:generate`. Don't hand-write migrations.
  Also update the "Database Schema — Data Model Reference" Linear document in the
  same change (see Project management section).
- **Adding API endpoints:** extend `appRouter` in `packages/api/src/routers/`.
  Use `publicProcedure` for open endpoints and `protectedProcedure` for
  auth-gated ones (see existing `healthCheck` / `privateData`).
- **Frontend data fetching:** use the oRPC client (`$lib/orpc`) with
  `createQuery` from `@tanstack/svelte-query`.
- Database is Cloudflare D1 (SQLite) via the `DB` Worker binding. A local
  `DATABASE_URL` is only for tooling.

## Current state

- **Theme + landing:** House Stark theme applied; hero landing with the nine
  house banners.
- **Schema:** full domain model in `packages/db/src/schema/` (houses, members,
  lineage, marriages, relations, wars, battles, dragons, deaths, events,
  locations). Documented in the Linear schema doc. Migrations not yet generated.
- **Seed:** `packages/db/src/seed/stark.ts` (`seedStark(db)`) — the nine houses
  plus a canonically accurate House Stark dataset (members, lineage, marriages,
  titles, deaths, wars/battles, events). Run it via the `dev.seed` oRPC mutation.
- **API:** public oRPC endpoints in `packages/api/src/routers/` — `houses.list`,
  `houses.getBySlug`, `members.getBySlug`, `tree.byHouse`, plus `dev.seed`.
- **Pages (apps/web):** `/tree` pan/zoom family-tree canvas with a house
  switcher and URL-driven right-side member detail dialog (`?member=<slug>`);
  `/house/[slug]` house detail (banner, words, seat, sigil, ties, members).
  Tree layout is a dependency-free module in `$lib/tree-layout.ts`.

### Running the seed

The D1 binding only exists inside the Worker, so seeding is done through the API:
start the app (`npm run dev`) after generating/applying migrations, then call the
`dev.seed` mutation (e.g. `POST {PUBLIC_SERVER_URL}/rpc/dev/seed`). It resets the
domain tables (auth tables untouched) and inserts the Stark dataset.

## Remaining / next

- Generate + apply the Drizzle migration (`npm run db:generate`), then seed.
- Seed the other eight houses' members.
- Map of Westeros with house territories.
- Auth-gated extras (favorites, notes, custom highlight paths).
