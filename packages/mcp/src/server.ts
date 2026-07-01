import { StreamableHTTPTransport } from "@hono/mcp";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { Hono } from "hono";

import { registerAssetTools } from "./tools/assets";
import { registerRecordTools } from "./tools/records";

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
  registerRecordTools(server, bindings.DB);
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
