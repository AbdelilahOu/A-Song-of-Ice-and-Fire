import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

import { timestamps } from "./_helpers";

export const HOUSE_STATUS = ["ruling", "extant", "extinct", "exiled", "cadet"] as const;
export type HouseStatus = (typeof HOUSE_STATUS)[number];

export const HOUSE_RELATION_TYPE = [
  "alliance",
  "rivalry",
  "feud",
  "war",
  "vassalage",
  "cadet_branch",
  "marriage_pact",
] as const;
export type HouseRelationType = (typeof HOUSE_RELATION_TYPE)[number];

export const house = sqliteTable(
  "house",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    slug: text("slug").notNull().unique(),
    name: text("name").notNull(),
    fullName: text("full_name"),
    words: text("words"),
    region: text("region"),
    seat: text("seat"),
    sigilDescription: text("sigil_description"),
    sigilColors: text("sigil_colors"),
    foundedYear: integer("founded_year"),
    founderId: integer("founder_id"),
    currentLordId: integer("current_lord_id"),
    status: text("status", { enum: HOUSE_STATUS }).notNull().default("extant"),
    isGreatHouse: integer("is_great_house", { mode: "boolean" }).notNull().default(false),
    summary: text("summary"),
    history: text("history"),
    bannerPath: text("banner_path"),
    framePath: text("frame_path"),
    ...timestamps,
  },
  (table) => [index("house_slug_idx").on(table.slug), index("house_region_idx").on(table.region)],
);

export const houseRelation = sqliteTable(
  "house_relation",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    houseAId: integer("house_a_id")
      .notNull()
      .references(() => house.id, { onDelete: "cascade" }),
    houseBId: integer("house_b_id")
      .notNull()
      .references(() => house.id, { onDelete: "cascade" }),
    type: text("type", { enum: HOUSE_RELATION_TYPE }).notNull(),
    startYear: integer("start_year"),
    endYear: integer("end_year"),
    isCurrent: integer("is_current", { mode: "boolean" }).notNull().default(true),
    description: text("description"),
    ...timestamps,
  },
  (table) => [
    index("house_relation_a_idx").on(table.houseAId),
    index("house_relation_b_idx").on(table.houseBId),
    index("house_relation_type_idx").on(table.type),
  ],
);
