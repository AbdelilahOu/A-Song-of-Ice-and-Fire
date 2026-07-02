import type { RouterClient } from "@orpc/server";

import { protectedProcedure, publicProcedure } from "../index";
import { housesRouter } from "./houses";
import { membersRouter } from "./members";
import { timelineRouter } from "./timeline";
import { treeRouter } from "./tree";

export const appRouter = {
  healthCheck: publicProcedure.handler(() => {
    return "OK";
  }),
  privateData: protectedProcedure.handler(({ context }) => {
    return {
      message: "This is private",
      user: context.session?.user,
    };
  }),
  houses: housesRouter,
  members: membersRouter,
  tree: treeRouter,
  timeline: timelineRouter,
};
export type AppRouter = typeof appRouter;
export type AppRouterClient = RouterClient<typeof appRouter>;
