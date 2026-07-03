import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

import { dragon } from "./dragons";
import { member } from "./members";
import { timestamps } from "./_helpers";

export const ACHIEVEMENT_CATEGORY = [
  "military",
  "political",
  "dynastic",
  "dragon",
  "construction",
  "cultural",
  "infamy",
  "other",
] as const;
export type AchievementCategory = (typeof ACHIEVEMENT_CATEGORY)[number];

// A notable deed or accomplishment attributed to a single subject — either a
// member or a dragon (exactly one of the two references is set per row).
export const achievement = sqliteTable(
  "achievement",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    memberId: integer("member_id").references(() => member.id, {
      onDelete: "cascade",
    }),
    dragonId: integer("dragon_id").references(() => dragon.id, {
      onDelete: "cascade",
    }),
    title: text("title").notNull(),
    year: integer("year"),
    category: text("category", { enum: ACHIEVEMENT_CATEGORY }),
    description: text("description"),
    sortOrder: integer("sort_order").notNull().default(0),
    ...timestamps,
  },
  (table) => [
    index("achievement_member_idx").on(table.memberId),
    index("achievement_dragon_idx").on(table.dragonId),
    index("achievement_year_idx").on(table.year),
  ],
);
