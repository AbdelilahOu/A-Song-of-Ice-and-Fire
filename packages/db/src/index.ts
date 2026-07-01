import { env } from "@GOT-familly-tree/env/server";
import { drizzle } from "drizzle-orm/d1";

import * as schema from "./schema";

export function createDbClient(d1: D1Database) {
  return drizzle(d1, { schema });
}

export function createDb() {
  return createDbClient(env.DB);
}

export type Db = ReturnType<typeof createDbClient>;
