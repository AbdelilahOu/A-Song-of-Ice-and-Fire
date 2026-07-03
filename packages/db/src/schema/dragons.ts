import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

import { timestamps } from "./_helpers";
import { battle } from "./conflicts";
import { member } from "./members";

export const DRAGON_STATUS = ["alive", "dead", "unknown", "wild"] as const;
export type DragonStatus = (typeof DRAGON_STATUS)[number];

export const DRAGON_SIZE = ["hatchling", "small", "medium", "large", "great", "unknown"] as const;
export type DragonSize = (typeof DRAGON_SIZE)[number];

export const dragon = sqliteTable(
  "dragon",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    slug: text("slug").notNull().unique(),
    name: text("name").notNull(),
    epithet: text("epithet"),
    status: text("status", { enum: DRAGON_STATUS }).notNull().default("unknown"),
    size: text("size", { enum: DRAGON_SIZE }).notNull().default("unknown"),
    color: text("color"),
    bornYear: integer("born_year"),
    diedYear: integer("died_year"),
    notableRiderId: integer("notable_rider_id").references(() => member.id, {
      onDelete: "set null",
    }),
    killedInBattleId: integer("killed_in_battle_id").references(() => battle.id, {
      onDelete: "set null",
    }),
    description: text("description"),
    notableFor: text("notable_for"),
    fate: text("fate"),
    ...timestamps,
  },
  (table) => [
    index("dragon_slug_idx").on(table.slug),
    index("dragon_rider_idx").on(table.notableRiderId),
    index("dragon_status_idx").on(table.status),
  ],
);

export const dragonRider = sqliteTable(
  "dragon_rider",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    dragonId: integer("dragon_id")
      .notNull()
      .references(() => dragon.id, { onDelete: "cascade" }),
    memberId: integer("member_id")
      .notNull()
      .references(() => member.id, { onDelete: "cascade" }),
    startYear: integer("start_year"),
    endYear: integer("end_year"),
    isNotable: integer("is_notable", { mode: "boolean" }).notNull().default(false),
    notes: text("notes"),
    ...timestamps,
  },
  (table) => [
    index("dragon_rider_dragon_idx").on(table.dragonId),
    index("dragon_rider_member_idx").on(table.memberId),
  ],
);
