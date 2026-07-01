import { StreamableHTTPTransport } from "@hono/mcp";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { Hono } from "hono";

import { registerAssetTools } from "./tools/assets";
import { registerRecordTools } from "./tools/records";

export type WesterosMcpBindings = {
  DB: D1Database;
  ASSETS: R2Bucket;
};

export function createWesterosMcpApp(bindings: WesterosMcpBindings) {
  const server = new McpServer({
    name: "westeros-lineages",
    version: "0.1.0",
  });
  registerRecordTools(server, bindings.DB);
  registerAssetTools(server, bindings.ASSETS);

  const transport = new StreamableHTTPTransport();
  let isConnected = false;

  const app = new Hono();

  app.get("/assets/*", async (c) => {
    const key = decodeURIComponent(c.req.path.replace(/^\/assets\//, ""));
    const object = await bindings.ASSETS.get(key);
    if (!object) {
      return c.notFound();
    }

    const headers = new Headers();
    object.writeHttpMetadata(headers);
    headers.set("etag", object.httpEtag);
    return new Response(object.body, { headers });
  });

  app.all("/mcp", async (c) => {
    if (!isConnected) {
      await server.connect(transport);
      isConnected = true;
    }
    return transport.handleRequest(c);
  });

  return app;
}
