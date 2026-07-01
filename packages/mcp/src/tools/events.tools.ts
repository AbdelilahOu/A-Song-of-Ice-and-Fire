import type { Db } from "@GOT-familly-tree/db";
import { EVENT_PARTICIPANT_ROLE, EVENT_TYPE } from "@GOT-familly-tree/db/schema/index";
import { addEventParticipant, upsertEvent } from "@GOT-familly-tree/db/services/index";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import * as z from "zod/v4";

import { asText, year } from "./shared";

export function registerEventTools(server: McpServer, db: Db) {
  server.registerTool(
    "insert_event",
    {
      description:
        "Create or update a timeline event by slug (idempotent). locationSlug/warSlug/battleSlug reference existing records.",
      inputSchema: {
        slug: z.string(),
        name: z.string(),
        type: z.enum(EVENT_TYPE).optional(),
        year: year.optional(),
        endYear: year.optional(),
        locationSlug: z.string().optional(),
        warSlug: z.string().optional(),
        battleSlug: z.string().optional(),
        description: z.string().optional(),
      },
    },
    async (input) => asText(await upsertEvent(db, input)),
  );

  server.registerTool(
    "add_event_participant",
    {
      description:
        "Tie a member and/or house to an event. Provide at least memberSlug or houseSlug. Deduplicated on (event, member, house).",
      inputSchema: {
        eventSlug: z.string(),
        memberSlug: z.string().optional(),
        houseSlug: z.string().optional(),
        role: z.enum(EVENT_PARTICIPANT_ROLE).optional(),
        notes: z.string().optional(),
      },
    },
    async (input) => asText(await addEventParticipant(db, input)),
  );
}
