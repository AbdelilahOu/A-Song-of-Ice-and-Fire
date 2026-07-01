import type { Db } from "@GOT-familly-tree/db";
import { house, member } from "@GOT-familly-tree/db/schema/index";
import {
  addMarriage,
  addMemberAllegiance,
  addMemberRelation,
  addMemberTitle,
  recordDeath,
  upsertMember,
} from "@GOT-familly-tree/db/services/index";
import {
  ALLEGIANCE_ROLE,
  GENDER,
  MARRIAGE_STATUS,
  MEMBER_RELATION_TYPE,
  MEMBER_STATUS,
} from "@GOT-familly-tree/db/schema/index";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { asc, eq } from "drizzle-orm";
import * as z from "zod/v4";

import { asText, year } from "./shared";

export function registerMemberTools(server: McpServer, db: Db) {
  server.registerTool(
    "list_members",
    {
      description: "List members (slug, name, houseId). Optionally filter to one house by slug.",
      inputSchema: {
        houseSlug: z.string().optional(),
        limit: z.number().int().min(1).max(500).default(200),
      },
    },
    async ({ houseSlug, limit }) => {
      const houseRow = houseSlug
        ? await db.query.house.findFirst({
            where: eq(house.slug, houseSlug),
            columns: { id: true },
          })
        : null;
      if (houseSlug && !houseRow) {
        throw new Error(`House "${houseSlug}" does not exist.`);
      }
      const rows = await db.query.member.findMany({
        where: houseRow ? eq(member.houseId, houseRow.id) : undefined,
        columns: { id: true, slug: true, name: true, surname: true, houseId: true, status: true },
        orderBy: [asc(member.name)],
        limit,
      });
      return asText(rows);
    },
  );

  server.registerTool(
    "get_member",
    {
      description: "Get one member by slug with its full row, or null if it does not exist.",
      inputSchema: { slug: z.string() },
    },
    async ({ slug }) =>
      asText((await db.query.member.findFirst({ where: eq(member.slug, slug) })) ?? null),
  );

  server.registerTool(
    "insert_member",
    {
      description:
        "Create or update a member by slug (idempotent). houseSlug/fatherSlug/motherSlug reference existing records.",
      inputSchema: {
        slug: z.string(),
        name: z.string(),
        fullName: z.string().optional(),
        surname: z.string().optional(),
        epithet: z.string().optional(),
        houseSlug: z.string().optional(),
        fatherSlug: z.string().optional(),
        motherSlug: z.string().optional(),
        gender: z.enum(GENDER).optional(),
        status: z.enum(MEMBER_STATUS).optional(),
        isBastard: z.boolean().optional(),
        isLegitimized: z.boolean().optional(),
        bornYear: year.optional(),
        diedYear: year.optional(),
        culture: z.string().optional(),
        portraitPath: z.string().optional(),
        bio: z.string().optional(),
        notableFor: z.string().optional(),
      },
    },
    async (input) => asText(await upsertMember(db, input)),
  );

  server.registerTool(
    "add_title",
    {
      description: "Give a member a title. Deduplicated on (member, title).",
      inputSchema: {
        memberSlug: z.string(),
        title: z.string(),
        startYear: year.optional(),
        endYear: year.optional(),
        isCurrent: z.boolean().optional(),
      },
    },
    async (input) => asText(await addMemberTitle(db, input)),
  );

  server.registerTool(
    "add_marriage",
    {
      description: "Marry two members. Deduplicated; the pair is unordered.",
      inputSchema: {
        spouseASlug: z.string(),
        spouseBSlug: z.string(),
        status: z.enum(MARRIAGE_STATUS).optional(),
        startYear: year.optional(),
        endYear: year.optional(),
        isSecret: z.boolean().optional(),
        notes: z.string().optional(),
      },
    },
    async (input) => asText(await addMarriage(db, input)),
  );

  server.registerTool(
    "add_member_relation",
    {
      description:
        "Record a non-lineage relation between members (sibling, ward, sworn_sword, ...). Deduplicated on (from, to, type).",
      inputSchema: {
        fromSlug: z.string(),
        toSlug: z.string(),
        type: z.enum(MEMBER_RELATION_TYPE),
        notes: z.string().optional(),
      },
    },
    async (input) => asText(await addMemberRelation(db, input)),
  );

  server.registerTool(
    "add_allegiance",
    {
      description:
        "Affiliate a member with a house over time. Deduplicated on (member, house, role).",
      inputSchema: {
        memberSlug: z.string(),
        houseSlug: z.string(),
        role: z.enum(ALLEGIANCE_ROLE).optional(),
        isCurrent: z.boolean().optional(),
        startYear: year.optional(),
        endYear: year.optional(),
        notes: z.string().optional(),
      },
    },
    async (input) => asText(await addMemberAllegiance(db, input)),
  );

  server.registerTool(
    "record_death",
    {
      description:
        "Record or update a member's death (one per member). killerSlug/battleSlug/locationSlug reference existing records.",
      inputSchema: {
        memberSlug: z.string(),
        year: year.optional(),
        locationSlug: z.string().optional(),
        cause: z.string().optional(),
        killerSlug: z.string().optional(),
        battleSlug: z.string().optional(),
        description: z.string().optional(),
        isConfirmed: z.boolean().optional(),
      },
    },
    async (input) => asText(await recordDeath(db, input)),
  );
}
