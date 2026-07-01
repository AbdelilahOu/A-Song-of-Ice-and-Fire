import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

import { timestamps } from "./_helpers";
import { house } from "./houses";

export const LOCATION_TYPE = [
  "castle",
  "stronghold",
  "city",
  "town",
  "region",
  "island",
  "ruin",
  "landmark",
  "other",
] as const;
export type LocationType = (typeof LOCATION_TYPE)[number];

export const location = sqliteTable(
  "location",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    slug: text("slug").notNull().unique(),
    name: text("name").notNull(),
    type: text("type", { enum: LOCATION_TYPE }).notNull().default("other"),
    region: text("region"),
    controllingHouseId: integer("controlling_house_id").references(
      () => house.id,
      { onDelete: "set null" },
    ),
    description: text("description"),
    ...timestamps,
  },
  (table) => [
    index("location_slug_idx").on(table.slug),
    index("location_house_idx").on(table.controllingHouseId),
    index("location_region_idx").on(table.region),
  ],
);
