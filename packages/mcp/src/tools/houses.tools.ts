import type { Db } from "@GOT-familly-tree/db";
import { house } from "@GOT-familly-tree/db/schema/index";
import { addHouseRelation, upsertHouse } from "@GOT-familly-tree/db/services/index";
import { HOUSE_RELATION_TYPE, HOUSE_STATUS } from "@GOT-familly-tree/db/schema/index";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { asc, eq } from "drizzle-orm";
import * as z from "zod/v4";

import { asText, year } from "./shared";

export function registerHouseTools(server: McpServer, db: Db) {
  server.registerTool(
    "list_houses",
    {
      description: "List all houses (slug, name, region) to see what exists.",
      inputSchema: {},
    },
    async () =>
      asText(
        await db.query.house.findMany({
          columns: { id: true, slug: true, name: true, region: true, status: true },
          orderBy: [asc(house.name)],
        }),
      ),
  );

  server.registerTool(
    "get_house",
    {
      description: "Get one house by slug with its full row, or null if it does not exist.",
      inputSchema: { slug: z.string() },
    },
    async ({ slug }) =>
      asText((await db.query.house.findFirst({ where: eq(house.slug, slug) })) ?? null),
  );

  server.registerTool(
    "insert_house",
    {
      description:
        "Create or update a house by slug (idempotent). founderSlug/currentLordSlug reference existing members.",
      inputSchema: {
        slug: z.string(),
        name: z.string(),
        fullName: z.string().optional(),
        words: z.string().optional(),
        region: z.string().optional(),
        seat: z.string().optional(),
        sigilDescription: z.string().optional(),
        sigilColors: z.string().optional(),
        foundedYear: year.optional(),
        founderSlug: z.string().optional(),
        currentLordSlug: z.string().optional(),
        status: z.enum(HOUSE_STATUS).optional(),
        isGreatHouse: z.boolean().optional(),
        summary: z.string().optional(),
        history: z.string().optional(),
        bannerPath: z.string().optional(),
        framePath: z.string().optional(),
      },
    },
    async (input) => asText(await upsertHouse(db, input)),
  );

  server.registerTool(
    "link_houses",
    {
      description:
        "Relate two houses (alliance, rivalry, vassalage, ...). Deduplicated per type; the pair is unordered.",
      inputSchema: {
        houseASlug: z.string(),
        houseBSlug: z.string(),
        type: z.enum(HOUSE_RELATION_TYPE),
        startYear: year.optional(),
        endYear: year.optional(),
        isCurrent: z.boolean().optional(),
        description: z.string().optional(),
      },
    },
    async (input) => asText(await addHouseRelation(db, input)),
  );
}
