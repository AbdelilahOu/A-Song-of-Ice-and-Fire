import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import * as z from "zod/v4";

import { deleteAsset, getAssetMetadata, listAssets, uploadAsset } from "../assets/r2";

function asText(data: unknown) {
  return {
    content: [{ type: "text" as const, text: JSON.stringify(data, null, 2) }],
  };
}

export function registerAssetTools(server: McpServer, bucket: R2Bucket, assetBaseUrl: string) {
  server.registerTool(
    "upload_asset",
    {
      description:
        "Upload an AI-generated image or asset to R2. Returns a Worker-proxied /assets URL.",
      inputSchema: {
        key: z.string(),
        contentBase64: z.string(),
        contentType: z.string(),
      },
    },
    async (input) => asText(await uploadAsset(bucket, assetBaseUrl, input)),
  );

  server.registerTool(
    "list_assets",
    {
      description: "List uploaded R2 assets.",
      inputSchema: {
        prefix: z.string().optional(),
        cursor: z.string().optional(),
        limit: z.number().int().min(1).max(500).default(100),
      },
    },
    async ({ prefix, cursor, limit }) =>
      asText(await listAssets(bucket, assetBaseUrl, prefix, cursor, limit)),
  );

  server.registerTool(
    "get_asset_metadata",
    {
      description: "Read metadata for one R2 asset.",
      inputSchema: {
        key: z.string(),
      },
    },
    async ({ key }) => asText(await getAssetMetadata(bucket, assetBaseUrl, key)),
  );

  server.registerTool(
    "delete_asset",
    {
      description: "Delete one R2 asset by key.",
      inputSchema: {
        key: z.string(),
      },
    },
    async ({ key }) => asText(await deleteAsset(bucket, key)),
  );
}
