import type { Db } from "@GOT-familly-tree/db";
import { LOCATION_TYPE } from "@GOT-familly-tree/db/schema/index";
import { upsertLocation } from "@GOT-familly-tree/db/services/index";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import * as z from "zod/v4";

import { asText } from "./shared";

export function registerLocationTools(server: McpServer, db: Db) {
  server.registerTool(
    "insert_location",
    {
      description: "Create or update a location by slug (idempotent).",
      inputSchema: {
        slug: z.string(),
        name: z.string(),
        type: z.enum(LOCATION_TYPE).optional(),
        region: z.string().optional(),
        controllingHouseSlug: z.string().optional(),
        description: z.string().optional(),
      },
    },
    async (input) => asText(await upsertLocation(db, input)),
  );
}
