import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

import { timestamps } from "./_helpers";
import { house } from "./houses";
import { location } from "./locations";
import { member } from "./members";

export const PARTICIPANT_ROLE = [
  "attacker",
  "defender",
  "instigator",
  "ally",
  "commander",
  "combatant",
] as const;
export type ParticipantRole = (typeof PARTICIPANT_ROLE)[number];

export const war = sqliteTable(
  "war",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    slug: text("slug").notNull().unique(),
    name: text("name").notNull(), // "War of the Five Kings", "Dance of the Dragons"
    startYear: integer("start_year"),
    endYear: integer("end_year"),
    description: text("description"),
    outcome: text("outcome"),
    victorHouseId: integer("victor_house_id").references(() => house.id, {
      onDelete: "set null",
    }),
    ...timestamps,
  },
  (table) => [index("war_slug_idx").on(table.slug)],
);

export const battle = sqliteTable(
  "battle",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    slug: text("slug").notNull().unique(),
    name: text("name").notNull(), // "Battle of the Blackwater"
    warId: integer("war_id").references(() => war.id, { onDelete: "set null" }),
    year: integer("year"),
    locationId: integer("location_id").references(() => location.id, {
      onDelete: "set null",
    }),
    description: text("description"),
    outcome: text("outcome"),
    victorSide: text("victor_side"), // free-text faction/side label
    ...timestamps,
  },
  (table) => [
    index("battle_slug_idx").on(table.slug),
    index("battle_war_idx").on(table.warId),
    index("battle_location_idx").on(table.locationId),
  ],
);

// Houses and/or members taking part in a war. Either houseId or memberId may be
// set (or both, e.g. a member fighting under a house banner).
export const warParticipant = sqliteTable(
  "war_participant",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    warId: integer("war_id")
      .notNull()
      .references(() => war.id, { onDelete: "cascade" }),
    houseId: integer("house_id").references(() => house.id, {
      onDelete: "cascade",
    }),
    memberId: integer("member_id").references(() => member.id, {
      onDelete: "cascade",
    }),
    side: text("side"), // faction name, e.g. "Blacks" / "Greens"
    role: text("role", { enum: PARTICIPANT_ROLE }),
    outcome: text("outcome"), // "victor" | "defeated" | ...
    ...timestamps,
  },
  (table) => [
    index("war_participant_war_idx").on(table.warId),
    index("war_participant_house_idx").on(table.houseId),
    index("war_participant_member_idx").on(table.memberId),
  ],
);

export const battleParticipant = sqliteTable(
  "battle_participant",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    battleId: integer("battle_id")
      .notNull()
      .references(() => battle.id, { onDelete: "cascade" }),
    houseId: integer("house_id").references(() => house.id, {
      onDelete: "cascade",
    }),
    memberId: integer("member_id").references(() => member.id, {
      onDelete: "cascade",
    }),
    side: text("side"),
    role: text("role", { enum: PARTICIPANT_ROLE }),
    wasCommander: integer("was_commander", { mode: "boolean" })
      .notNull()
      .default(false),
    wasKilled: integer("was_killed", { mode: "boolean" })
      .notNull()
      .default(false),
    ...timestamps,
  },
  (table) => [
    index("battle_participant_battle_idx").on(table.battleId),
    index("battle_participant_house_idx").on(table.houseId),
    index("battle_participant_member_idx").on(table.memberId),
  ],
);
