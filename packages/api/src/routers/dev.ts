import { seedStark } from "@GOT-familly-tree/db/seed/stark";

import { publicProcedure } from "../index";

// Development helper to populate the database. This resets all domain tables
// (auth tables are untouched) and inserts the House Stark seed set. Intended for
// local/dev use on this personal project.
export const devRouter = {
  seed: publicProcedure.handler(async ({ context }) => {
    const result = await seedStark(context.db);
    return { seeded: true, ...result };
  }),
};
