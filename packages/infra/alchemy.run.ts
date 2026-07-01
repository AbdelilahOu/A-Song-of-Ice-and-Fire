import alchemy from "alchemy";
import { SvelteKit } from "alchemy/cloudflare";
import { Worker } from "alchemy/cloudflare";
import { D1Database } from "alchemy/cloudflare";
import { R2Bucket } from "alchemy/cloudflare";
import { config } from "dotenv";

config({ path: "./.env" });
config({ path: "../../apps/web/.env" });
config({ path: "../../apps/server/.env" });

const app = await alchemy("GOT-familly-tree");

// Custom domains (owned zone: ar7al.dev). Only attached on deploy; local dev
// keeps using localhost via the `dev` config below.
const WEB_DOMAIN = "westeros.ar7al.dev";
const API_DOMAIN = "api.westeros.ar7al.dev";
const ASSET_DOMAIN = "assets.westeros.ar7al.dev";

const isDev = app.local;
const WEB_URL = isDev ? "http://localhost:5173" : `https://${WEB_DOMAIN}`;
const API_URL = isDev ? "http://localhost:3000" : `https://${API_DOMAIN}`;
const ASSET_URL = `https://${ASSET_DOMAIN}`;

const db = await D1Database("database", {
  name: "westeros-db",
  migrationsDir: "../../packages/db/src/migrations",
});

const assets = await R2Bucket("assets", {
  name: "westeros-assets",
  ...(isDev
    ? {}
    : {
        domains: [
          {
            domain: ASSET_DOMAIN,
            enabled: true,
            adopt: true,
          },
        ],
      }),
});

export const server = await Worker("server", {
  name: "westeros-api",
  cwd: "../../apps/server",
  entrypoint: "src/index.ts",
  compatibility: "node",
  url: true,
  ...(isDev ? {} : { domains: [API_DOMAIN] }),
  bindings: {
    DB: db,
    ASSETS: assets,
    ASSET_PUBLIC_URL: ASSET_URL,
    CORS_ORIGIN: WEB_URL,
    BETTER_AUTH_SECRET: alchemy.secret.env.BETTER_AUTH_SECRET!,
    BETTER_AUTH_URL: API_URL,
  },
  dev: {
    port: 3000,
  },
});

export const web = await SvelteKit("web", {
  name: "westeros-web",
  cwd: "../../apps/web",
  ...(isDev ? {} : { domains: [WEB_DOMAIN] }),
  bindings: {
    PUBLIC_SERVER_URL: isDev ? server.url! : API_URL,
    PUBLIC_ASSET_URL: ASSET_URL,
  },
  dev: {
    domain: "localhost:5173",
  },
});

console.log(`Web    -> ${isDev ? web.url : `https://${WEB_DOMAIN}`}`);
console.log(`Server -> ${isDev ? server.url : `https://${API_DOMAIN}`}`);
console.log(`Assets -> ${ASSET_URL}`);

await app.finalize();
