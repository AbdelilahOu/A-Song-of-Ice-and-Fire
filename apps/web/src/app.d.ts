import type { CloudflareEnv } from "../../../packages/env/env";

declare global {
  namespace App {
    interface Platform {
      env: CloudflareEnv;
      ctx: ExecutionContext;
      caches: CacheStorage;
      cf: IncomingRequestCfProperties;
    }
  }
}

export {};
