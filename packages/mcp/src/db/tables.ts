export type SeedTableName = keyof typeof seedTables;

export type SeedColumn = {
  name: string;
  type: "integer" | "text" | "boolean" | "timestamp";
  required?: boolean;
  generated?: boolean;
  unique?: boolean;
};

export type SeedTable = {
  name: string;
  description: string;
  columns: SeedColumn[];
};

const timestamps = [
  { name: "created_at", type: "timestamp", generated: true },
  { name: "updated_at", type: "timestamp", generated: true },
] satisfies SeedColumn[];

export const seedTables = {
  house: {
    name: "house",
    description: "Great and minor Westerosi houses.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "slug", type: "text", required: true, unique: true },
      { name: "name", type: "text", required: true },
      { name: "full_name", type: "text" },
      { name: "words", type: "text" },
      { name: "region", type: "text" },
      { name: "seat", type: "text" },
      { name: "sigil_description", type: "text" },
      { name: "sigil_colors", type: "text" },
      { name: "founded_year", type: "integer" },
      { name: "founder_id", type: "integer" },
      { name: "current_lord_id", type: "integer" },
      { name: "status", type: "text" },
      { name: "is_great_house", type: "boolean" },
      { name: "summary", type: "text" },
      { name: "history", type: "text" },
      { name: "banner_path", type: "text" },
      { name: "frame_path", type: "text" },
      ...timestamps,
    ],
  },
  house_relation: {
    name: "house_relation",
    description: "Directional and undirected relationships between houses.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "house_a_id", type: "integer", required: true },
      { name: "house_b_id", type: "integer", required: true },
      { name: "type", type: "text", required: true },
      { name: "start_year", type: "integer" },
      { name: "end_year", type: "integer" },
      { name: "is_current", type: "boolean" },
      { name: "description", type: "text" },
      ...timestamps,
    ],
  },
  location: {
    name: "location",
    description: "Castles, regions, cities, landmarks, and other places.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "slug", type: "text", required: true, unique: true },
      { name: "name", type: "text", required: true },
      { name: "type", type: "text" },
      { name: "region", type: "text" },
      { name: "controlling_house_id", type: "integer" },
      { name: "description", type: "text" },
      ...timestamps,
    ],
  },
  member: {
    name: "member",
    description: "People in Westerosi house lineages.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "slug", type: "text", required: true, unique: true },
      { name: "name", type: "text", required: true },
      { name: "full_name", type: "text" },
      { name: "surname", type: "text" },
      { name: "epithet", type: "text" },
      { name: "house_id", type: "integer" },
      { name: "father_id", type: "integer" },
      { name: "mother_id", type: "integer" },
      { name: "gender", type: "text" },
      { name: "status", type: "text" },
      { name: "is_bastard", type: "boolean" },
      { name: "is_legitimized", type: "boolean" },
      { name: "born_year", type: "integer" },
      { name: "died_year", type: "integer" },
      { name: "culture", type: "text" },
      { name: "portrait_path", type: "text" },
      { name: "bio", type: "text" },
      { name: "notable_for", type: "text" },
      ...timestamps,
    ],
  },
  member_title: {
    name: "member_title",
    description: "Titles held by members over time.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "member_id", type: "integer", required: true },
      { name: "title", type: "text", required: true },
      { name: "start_year", type: "integer" },
      { name: "end_year", type: "integer" },
      { name: "is_current", type: "boolean" },
      ...timestamps,
    ],
  },
  marriage: {
    name: "marriage",
    description: "Marriage or betrothal relationships between members.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "spouse_a_id", type: "integer", required: true },
      { name: "spouse_b_id", type: "integer", required: true },
      { name: "status", type: "text" },
      { name: "start_year", type: "integer" },
      { name: "end_year", type: "integer" },
      { name: "is_secret", type: "boolean" },
      { name: "notes", type: "text" },
      ...timestamps,
    ],
  },
  member_relation: {
    name: "member_relation",
    description: "Non-lineage relationships between members.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "from_member_id", type: "integer", required: true },
      { name: "to_member_id", type: "integer", required: true },
      { name: "type", type: "text", required: true },
      { name: "notes", type: "text" },
      ...timestamps,
    ],
  },
  member_allegiance: {
    name: "member_allegiance",
    description: "House affiliations for a member over time.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "member_id", type: "integer", required: true },
      { name: "house_id", type: "integer", required: true },
      { name: "role", type: "text" },
      { name: "is_current", type: "boolean" },
      { name: "start_year", type: "integer" },
      { name: "end_year", type: "integer" },
      { name: "notes", type: "text" },
      ...timestamps,
    ],
  },
  war: {
    name: "war",
    description: "Major wars and conflicts.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "slug", type: "text", required: true, unique: true },
      { name: "name", type: "text", required: true },
      { name: "start_year", type: "integer" },
      { name: "end_year", type: "integer" },
      { name: "description", type: "text" },
      { name: "outcome", type: "text" },
      { name: "victor_house_id", type: "integer" },
      ...timestamps,
    ],
  },
  battle: {
    name: "battle",
    description: "Battles tied to wars, locations, and participants.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "slug", type: "text", required: true, unique: true },
      { name: "name", type: "text", required: true },
      { name: "war_id", type: "integer" },
      { name: "year", type: "integer" },
      { name: "location_id", type: "integer" },
      { name: "description", type: "text" },
      { name: "outcome", type: "text" },
      { name: "victor_side", type: "text" },
      ...timestamps,
    ],
  },
  war_participant: {
    name: "war_participant",
    description: "Houses and members that participated in a war.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "war_id", type: "integer", required: true },
      { name: "house_id", type: "integer" },
      { name: "member_id", type: "integer" },
      { name: "side", type: "text" },
      { name: "role", type: "text" },
      { name: "outcome", type: "text" },
      ...timestamps,
    ],
  },
  battle_participant: {
    name: "battle_participant",
    description: "Houses and members that participated in a battle.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "battle_id", type: "integer", required: true },
      { name: "house_id", type: "integer" },
      { name: "member_id", type: "integer" },
      { name: "side", type: "text" },
      { name: "role", type: "text" },
      { name: "was_commander", type: "boolean" },
      { name: "was_killed", type: "boolean" },
      ...timestamps,
    ],
  },
  dragon: {
    name: "dragon",
    description: "Dragons and their core attributes.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "slug", type: "text", required: true, unique: true },
      { name: "name", type: "text", required: true },
      { name: "status", type: "text" },
      { name: "size", type: "text" },
      { name: "color", type: "text" },
      { name: "born_year", type: "integer" },
      { name: "died_year", type: "integer" },
      { name: "notable_rider_id", type: "integer" },
      { name: "killed_in_battle_id", type: "integer" },
      { name: "description", type: "text" },
      { name: "fate", type: "text" },
      ...timestamps,
    ],
  },
  dragon_rider: {
    name: "dragon_rider",
    description: "Dragon rider history.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "dragon_id", type: "integer", required: true },
      { name: "member_id", type: "integer", required: true },
      { name: "start_year", type: "integer" },
      { name: "end_year", type: "integer" },
      { name: "is_notable", type: "boolean" },
      { name: "notes", type: "text" },
      ...timestamps,
    ],
  },
  death: {
    name: "death",
    description: "Death records for members.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "member_id", type: "integer", required: true, unique: true },
      { name: "year", type: "integer" },
      { name: "location_id", type: "integer" },
      { name: "cause", type: "text" },
      { name: "killer_id", type: "integer" },
      { name: "battle_id", type: "integer" },
      { name: "description", type: "text" },
      { name: "is_confirmed", type: "boolean" },
      ...timestamps,
    ],
  },
  event: {
    name: "event",
    description: "Timeline events.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "slug", type: "text", required: true, unique: true },
      { name: "name", type: "text", required: true },
      { name: "type", type: "text" },
      { name: "year", type: "integer" },
      { name: "end_year", type: "integer" },
      { name: "location_id", type: "integer" },
      { name: "war_id", type: "integer" },
      { name: "battle_id", type: "integer" },
      { name: "description", type: "text" },
      ...timestamps,
    ],
  },
  event_participant: {
    name: "event_participant",
    description: "Members and houses tied to timeline events.",
    columns: [
      { name: "id", type: "integer", generated: true },
      { name: "event_id", type: "integer", required: true },
      { name: "member_id", type: "integer" },
      { name: "house_id", type: "integer" },
      { name: "role", type: "text" },
      { name: "notes", type: "text" },
      ...timestamps,
    ],
  },
} as const satisfies Record<string, SeedTable>;

export function getSeedTable(tableName: string) {
  const table = seedTables[tableName as SeedTableName];
  if (!table) {
    throw new Error(`Unknown seed table: ${tableName}`);
  }
  return table;
}

export function listSeedTables() {
  return Object.values(seedTables).map((table) => ({
    name: table.name,
    description: table.description,
  }));
}
