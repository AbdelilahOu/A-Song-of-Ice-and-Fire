import type { AnySQLiteColumn } from "drizzle-orm/sqlite-core";
import { index, integer, sqliteTable, text } from "drizzle-orm/sqlite-core";

import { timestamps } from "./_helpers";
import { house } from "./houses";

export const GENDER = ["male", "female", "unknown"] as const;
export type Gender = (typeof GENDER)[number];

export const MEMBER_STATUS = ["alive", "dead", "unknown"] as const;
export type MemberStatus = (typeof MEMBER_STATUS)[number];

export const MARRIAGE_STATUS = [
  "married",
  "widowed",
  "annulled",
  "separated",
  "betrothed",
] as const;
export type MarriageStatus = (typeof MARRIAGE_STATUS)[number];

// Non-lineage relations. Parent/child links live on the member row itself
// (fatherId / motherId); this table captures everything else.
export const MEMBER_RELATION_TYPE = [
  "sibling",
  "half_sibling",
  "twin",
  "guardian",
  "ward",
  "fostered_by",
  "paramour",
  "betrothed",
  "sworn_sword",
  "heir_of",
  "other",
] as const;
export type MemberRelationType = (typeof MEMBER_RELATION_TYPE)[number];

// A member's affiliation to a house over time (birth house, marriage, service).
export const ALLEGIANCE_ROLE = [
  "lord",
  "lady",
  "heir",
  "member",
  "bannerman",
  "sworn_sword",
  "household",
  "ward",
  "married_in",
] as const;
export type AllegianceRole = (typeof ALLEGIANCE_ROLE)[number];

export const member = sqliteTable(
  "member",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    slug: text("slug").notNull().unique(),
    name: text("name").notNull(), // common name, e.g. "Ned"
    fullName: text("full_name"), // "Eddard Stark"
    surname: text("surname"), // house surname or bastard name (Snow, Sand...)
    epithet: text("epithet"), // "The Mad", "Kingslayer"
    // Primary house of birth/allegiance. Nullable for house-less characters.
    houseId: integer("house_id").references(() => house.id, {
      onDelete: "set null",
    }),
    // Self references for lineage. AnySQLiteColumn breaks the type cycle.
    fatherId: integer("father_id").references((): AnySQLiteColumn => member.id, {
      onDelete: "set null",
    }),
    motherId: integer("mother_id").references((): AnySQLiteColumn => member.id, {
      onDelete: "set null",
    }),
    gender: text("gender", { enum: GENDER }).notNull().default("unknown"),
    status: text("status", { enum: MEMBER_STATUS }).notNull().default("unknown"),
    isBastard: integer("is_bastard", { mode: "boolean" }).notNull().default(false),
    isLegitimized: integer("is_legitimized", { mode: "boolean" }).notNull().default(false),
    bornYear: integer("born_year"),
    diedYear: integer("died_year"),
    culture: text("culture"),
    portraitPath: text("portrait_path"),
    bio: text("bio"),
    notableFor: text("notable_for"),
    ...timestamps,
  },
  (table) => [
    index("member_slug_idx").on(table.slug),
    index("member_house_idx").on(table.houseId),
    index("member_father_idx").on(table.fatherId),
    index("member_mother_idx").on(table.motherId),
    index("member_status_idx").on(table.status),
  ],
);

export const memberTitle = sqliteTable(
  "member_title",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    memberId: integer("member_id")
      .notNull()
      .references(() => member.id, { onDelete: "cascade" }),
    title: text("title").notNull(), // "Lord of Winterfell", "Hand of the King"
    startYear: integer("start_year"),
    endYear: integer("end_year"),
    isCurrent: integer("is_current", { mode: "boolean" }).notNull().default(false),
    ...timestamps,
  },
  (table) => [index("member_title_member_idx").on(table.memberId)],
);

export const marriage = sqliteTable(
  "marriage",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    spouseAId: integer("spouse_a_id")
      .notNull()
      .references(() => member.id, { onDelete: "cascade" }),
    spouseBId: integer("spouse_b_id")
      .notNull()
      .references(() => member.id, { onDelete: "cascade" }),
    status: text("status", { enum: MARRIAGE_STATUS }).notNull().default("married"),
    startYear: integer("start_year"),
    endYear: integer("end_year"),
    isSecret: integer("is_secret", { mode: "boolean" }).notNull().default(false),
    notes: text("notes"),
    ...timestamps,
  },
  (table) => [
    index("marriage_spouse_a_idx").on(table.spouseAId),
    index("marriage_spouse_b_idx").on(table.spouseBId),
  ],
);

export const memberRelation = sqliteTable(
  "member_relation",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    fromMemberId: integer("from_member_id")
      .notNull()
      .references(() => member.id, { onDelete: "cascade" }),
    toMemberId: integer("to_member_id")
      .notNull()
      .references(() => member.id, { onDelete: "cascade" }),
    type: text("type", { enum: MEMBER_RELATION_TYPE }).notNull(),
    notes: text("notes"),
    ...timestamps,
  },
  (table) => [
    index("member_relation_from_idx").on(table.fromMemberId),
    index("member_relation_to_idx").on(table.toMemberId),
    index("member_relation_type_idx").on(table.type),
  ],
);

export const memberAllegiance = sqliteTable(
  "member_allegiance",
  {
    id: integer("id").primaryKey({ autoIncrement: true }),
    memberId: integer("member_id")
      .notNull()
      .references(() => member.id, { onDelete: "cascade" }),
    houseId: integer("house_id")
      .notNull()
      .references(() => house.id, { onDelete: "cascade" }),
    role: text("role", { enum: ALLEGIANCE_ROLE }).notNull().default("member"),
    isCurrent: integer("is_current", { mode: "boolean" }).notNull().default(true),
    startYear: integer("start_year"),
    endYear: integer("end_year"),
    notes: text("notes"),
    ...timestamps,
  },
  (table) => [
    index("member_allegiance_member_idx").on(table.memberId),
    index("member_allegiance_house_idx").on(table.houseId),
  ],
);
