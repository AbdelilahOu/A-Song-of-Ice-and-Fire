import { createAuth } from "@GOT-familly-tree/auth";
import { createDb } from "@GOT-familly-tree/db";
import type { Context as HonoContext } from "hono";

export type CreateContextOptions = {
  context: HonoContext;
};

export async function createContext({ context }: CreateContextOptions) {
  const session = await createAuth().api.getSession({
    headers: context.req.raw.headers,
  });
  return {
    auth: null,
    db: createDb(),
    session,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
