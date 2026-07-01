import type { Db } from "@GOT-familly-tree/db";
import { DRAGON_SIZE, DRAGON_STATUS } from "@GOT-familly-tree/db/schema/index";
import { addDragonRider, upsertDragon } from "@GOT-familly-tree/db/services/index";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import * as z from "zod/v4";

import { asText, year } from "./shared";

export function registerDragonTools(server: McpServer, db: Db) {
  server.registerTool(
    "insert_dragon",
    {
      description:
        "Create or update a dragon by slug (idempotent). notableRiderSlug/killedInBattleSlug reference existing records.",
      inputSchema: {
        slug: z.string(),
        name: z.string(),
        status: z.enum(DRAGON_STATUS).optional(),
        size: z.enum(DRAGON_SIZE).optional(),
        color: z.string().optional(),
        bornYear: year.optional(),
        diedYear: year.optional(),
        notableRiderSlug: z.string().optional(),
        killedInBattleSlug: z.string().optional(),
        description: z.string().optional(),
        fate: z.string().optional(),
      },
    },
    async (input) => asText(await upsertDragon(db, input)),
  );

  server.registerTool(
    "add_dragon_rider",
    {
      description: "Bond a rider to a dragon. Deduplicated on (dragon, member).",
      inputSchema: {
        dragonSlug: z.string(),
        memberSlug: z.string(),
        startYear: year.optional(),
        endYear: year.optional(),
        isNotable: z.boolean().optional(),
        notes: z.string().optional(),
      },
    },
    async (input) => asText(await addDragonRider(db, input)),
  );
}
