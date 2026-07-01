import type { Db } from "@GOT-familly-tree/db";
import { PARTICIPANT_ROLE } from "@GOT-familly-tree/db/schema/index";
import {
  addBattleParticipant,
  addWarParticipant,
  upsertBattle,
  upsertWar,
} from "@GOT-familly-tree/db/services/index";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import * as z from "zod/v4";

import { asText, year } from "./shared";

export function registerConflictTools(server: McpServer, db: Db) {
  server.registerTool(
    "insert_war",
    {
      description: "Create or update a war by slug (idempotent).",
      inputSchema: {
        slug: z.string(),
        name: z.string(),
        startYear: year.optional(),
        endYear: year.optional(),
        description: z.string().optional(),
        outcome: z.string().optional(),
        victorHouseSlug: z.string().optional(),
      },
    },
    async (input) => asText(await upsertWar(db, input)),
  );

  server.registerTool(
    "insert_battle",
    {
      description:
        "Create or update a battle by slug (idempotent). warSlug/locationSlug reference existing records.",
      inputSchema: {
        slug: z.string(),
        name: z.string(),
        warSlug: z.string().optional(),
        year: year.optional(),
        locationSlug: z.string().optional(),
        description: z.string().optional(),
        outcome: z.string().optional(),
        victorSide: z.string().optional(),
      },
    },
    async (input) => asText(await upsertBattle(db, input)),
  );

  server.registerTool(
    "add_war_participant",
    {
      description:
        "Add a house and/or member to a war. Provide at least houseSlug or memberSlug. Deduplicated on (war, house, member).",
      inputSchema: {
        warSlug: z.string(),
        houseSlug: z.string().optional(),
        memberSlug: z.string().optional(),
        side: z.string().optional(),
        role: z.enum(PARTICIPANT_ROLE).optional(),
        outcome: z.string().optional(),
      },
    },
    async (input) => asText(await addWarParticipant(db, input)),
  );

  server.registerTool(
    "add_battle_participant",
    {
      description:
        "Add a house and/or member to a battle. Provide at least houseSlug or memberSlug. Deduplicated on (battle, house, member).",
      inputSchema: {
        battleSlug: z.string(),
        houseSlug: z.string().optional(),
        memberSlug: z.string().optional(),
        side: z.string().optional(),
        role: z.enum(PARTICIPANT_ROLE).optional(),
        wasCommander: z.boolean().optional(),
        wasKilled: z.boolean().optional(),
      },
    },
    async (input) => asText(await addBattleParticipant(db, input)),
  );
}
