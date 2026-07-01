import type { AnySQLiteColumn } from "drizzle-orm/sqlite-core";
import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

import { timestamps } from "./_helpers";
import { battle, war } from "./conflicts";
import { house } from "./houses";
import { location } from "./locations";
import { member } from "./members";

export const death = sqliteTable(
  "death",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    memberId: integer("member_id")
      .notNull()
      .unique()
      .references(() => member.id, { onDelete: "cascade" }),
    year: integer("year"),
    locationId: integer("location_id").references(() => location.id, {
      onDelete: "set null",
    }),
    cause: text("cause"),
    killerId: integer("killer_id").references((): AnySQLiteColumn => member.id, {
      onDelete: "set null",
    }),
    battleId: integer("battle_id").references(() => battle.id, {
      onDelete: "set null",
    }),
    description: text("description"),
    isConfirmed: integer("is_confirmed", { mode: "boolean" }).notNull().default(true),
    ...timestamps,
  },
  (table) => [
    index("death_member_idx").on(table.memberId),
    index("death_killer_idx").on(table.killerId),
    index("death_battle_idx").on(table.battleId),
  ],
);

export const EVENT_TYPE = [
  "birth",
  "death",
  "marriage",
  "battle",
  "war",
  "coronation",
  "alliance",
  "betrayal",
  "dragon_hatching",
  "founding",
  "other",
] as const;
export type EventType = (typeof EVENT_TYPE)[number];

export const event = sqliteTable(
  "event",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    slug: text("slug").notNull().unique(),
    name: text("name").notNull(),
    type: text("type", { enum: EVENT_TYPE }).notNull().default("other"),
    year: integer("year"),
    endYear: integer("end_year"),
    locationId: integer("location_id").references(() => location.id, {
      onDelete: "set null",
    }),
    warId: integer("war_id").references(() => war.id, { onDelete: "set null" }),
    battleId: integer("battle_id").references(() => battle.id, {
      onDelete: "set null",
    }),
    description: text("description"),
    ...timestamps,
  },
  (table) => [
    index("event_slug_idx").on(table.slug),
    index("event_year_idx").on(table.year),
    index("event_type_idx").on(table.type),
  ],
);

export const EVENT_PARTICIPANT_ROLE = [
  "subject",
  "witness",
  "instigator",
  "victim",
  "beneficiary",
  "other",
] as const;
export type EventParticipantRole = (typeof EVENT_PARTICIPANT_ROLE)[number];

export const eventParticipant = sqliteTable(
  "event_participant",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    eventId: integer("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    memberId: integer("member_id").references(() => member.id, {
      onDelete: "cascade",
    }),
    houseId: integer("house_id").references(() => house.id, {
      onDelete: "cascade",
    }),
    role: text("role", { enum: EVENT_PARTICIPANT_ROLE }),
    notes: text("notes"),
    ...timestamps,
  },
  (table) => [
    index("event_participant_event_idx").on(table.eventId),
    index("event_participant_member_idx").on(table.memberId),
    index("event_participant_house_idx").on(table.houseId),
  ],
);
