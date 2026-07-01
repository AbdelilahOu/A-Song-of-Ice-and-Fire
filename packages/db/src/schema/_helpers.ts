import { sql } from "drizzle-orm";
import { integer } from "drizzle-orm/sqlite-core";

// Shared audit columns. In-world dates are stored separately as plain integer
// "year" columns (see note below); these track row create/update time.
export const timestamps = {
  createdAt: integer("created_at", { mode: "timestamp_ms" })
    .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
    .notNull(),
  updatedAt: integer("updated_at", { mode: "timestamp_ms" })
    .default(sql`(cast(unixepoch('subsecond') * 1000 as integer))`)
    .$onUpdate(() => /* @__PURE__ */ new Date())
    .notNull(),
};

// In-world years are stored as signed integers using the Aegon's Conquest epoch:
// negative = BC (Before Conquest), positive = AC (After Conquest), 0 = the
// Conquest itself. Precise dates are rarely known, so a single year is enough.
export type WesterosYear = number;
