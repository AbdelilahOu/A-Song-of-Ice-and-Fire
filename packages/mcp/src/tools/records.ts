import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import * as z from "zod/v4";

import {
  createRecord,
  deleteRecord,
  getRecord,
  getRecordBySlug,
  listRecords,
  updateRecord,
  type JsonRecord,
} from "../db/crud";
import { getSeedTable, listSeedTables } from "../db/tables";

const jsonRecordSchema = z.record(
  z.string(),
  z.union([z.string(), z.number(), z.boolean(), z.null()]),
);

function asText(data: unknown) {
  return {
    content: [{ type: "text" as const, text: JSON.stringify(data, null, 2) }],
  };
}

export function registerRecordTools(server: McpServer, db: D1Database) {
  server.registerTool(
    "list_tables",
    {
      description: "List seedable Westeros domain tables. Auth tables are excluded.",
      inputSchema: {},
    },
    async () => asText(listSeedTables()),
  );

  server.registerTool(
    "describe_table",
    {
      description: "Describe columns for one seedable domain table.",
      inputSchema: {
        table: z.string(),
      },
    },
    async ({ table }) => asText(getSeedTable(table)),
  );

  server.registerTool(
    "list_records",
    {
      description: "List rows from a seedable domain table ordered by id.",
      inputSchema: {
        table: z.string(),
        limit: z.number().int().min(1).max(500).default(100),
        offset: z.number().int().min(0).default(0),
      },
    },
    async ({ table, limit, offset }) => asText(await listRecords(db, table, limit, offset)),
  );

  server.registerTool(
    "get_record",
    {
      description: "Get one row by id, or by slug for tables that have a slug column.",
      inputSchema: {
        table: z.string(),
        id: z.number().int().positive().optional(),
        slug: z.string().optional(),
      },
    },
    async ({ table, id, slug }) => {
      if (typeof id === "number") {
        return asText(await getRecord(db, table, id));
      }
      if (slug) {
        return asText(await getRecordBySlug(db, table, slug));
      }
      throw new Error("get_record requires id or slug");
    },
  );

  server.registerTool(
    "create_record",
    {
      description:
        "Create one row in a seedable domain table. Use database column names from describe_table.",
      inputSchema: {
        table: z.string(),
        data: jsonRecordSchema,
      },
    },
    async ({ table, data }) => asText(await createRecord(db, table, data as JsonRecord)),
  );

  server.registerTool(
    "update_record",
    {
      description:
        "Update one row by id in a seedable domain table. Use database column names from describe_table.",
      inputSchema: {
        table: z.string(),
        id: z.number().int().positive(),
        data: jsonRecordSchema,
      },
    },
    async ({ table, id, data }) => asText(await updateRecord(db, table, id, data as JsonRecord)),
  );

  server.registerTool(
    "delete_record",
    {
      description: "Delete one row by id from a seedable domain table.",
      inputSchema: {
        table: z.string(),
        id: z.number().int().positive(),
      },
    },
    async ({ table, id }) => asText(await deleteRecord(db, table, id)),
  );
}
