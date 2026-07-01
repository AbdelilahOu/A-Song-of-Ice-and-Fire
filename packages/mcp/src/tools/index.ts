import type { Db } from "@GOT-familly-tree/db";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";

import { registerConflictTools } from "./conflicts.tools";
import { registerDragonTools } from "./dragons.tools";
import { registerEventTools } from "./events.tools";
import { registerHouseTools } from "./houses.tools";
import { registerLocationTools } from "./locations.tools";
import { registerMemberTools } from "./members.tools";

export function registerDataTools(server: McpServer, db: Db) {
  registerHouseTools(server, db);
  registerMemberTools(server, db);
  registerLocationTools(server, db);
  registerConflictTools(server, db);
  registerDragonTools(server, db);
  registerEventTools(server, db);
}
