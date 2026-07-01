import { createDbClient } from "@GOT-familly-tree/db";
import { StreamableHTTPTransport } from "@hono/mcp";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { Hono } from "hono";

import { registerAssetTools } from "./tools/assets.tools";
import { registerDataTools } from "./tools/index";

export type WesterosMcpBindings = {
  DB: D1Database;
  ASSETS: R2Bucket;
  ASSET_PUBLIC_URL: string;
};

export function createWesterosMcpApp(bindings: WesterosMcpBindings) {
  const server = new McpServer({
    name: "westeros-lineages",
    version: "0.1.0",
  });

  const db = createDbClient(bindings.DB);
  registerDataTools(server, db);
  registerAssetTools(server, bindings.ASSETS, bindings.ASSET_PUBLIC_URL);

  const transport = new StreamableHTTPTransport();
  let isConnected = false;

  const app = new Hono();

  app.all("/mcp", async (c) => {
    if (!isConnected) {
      await server.connect(transport);
      isConnected = true;
    }
    return transport.handleRequest(c);
  });

  return app;
}
