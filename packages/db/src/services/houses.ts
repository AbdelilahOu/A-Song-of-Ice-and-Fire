import { and, eq, or } from "drizzle-orm";

import type { Db } from "../index";
import { house, houseRelation } from "../schema/houses";
import type { HouseRelationType, HouseStatus } from "../schema/houses";
import { resolveHouseId, resolveMemberId } from "./resolve";
import type { LinkOutcome, UpsertOutcome } from "./types";

export type House = typeof house.$inferSelect;
export type HouseRelation = typeof houseRelation.$inferSelect;

export type UpsertHouseInput = {
  slug: string;
  name: string;
  fullName?: string | null;
  words?: string | null;
  region?: string | null;
  seat?: string | null;
  sigilDescription?: string | null;
  sigilColors?: string | null;
  foundedYear?: number | null;
  founderSlug?: string;
  currentLordSlug?: string;
  status?: HouseStatus;
  isGreatHouse?: boolean;
  summary?: string | null;
  history?: string | null;
  bannerPath?: string | null;
  framePath?: string | null;
};

export async function upsertHouse(db: Db, input: UpsertHouseInput): Promise<UpsertOutcome<House>> {
  const values = {
    slug: input.slug,
    name: input.name,
    fullName: input.fullName,
    words: input.words,
    region: input.region,
    seat: input.seat,
    sigilDescription: input.sigilDescription,
    sigilColors: input.sigilColors,
    foundedYear: input.foundedYear,
    founderId: input.founderSlug ? await resolveMemberId(db, input.founderSlug) : undefined,
    currentLordId: input.currentLordSlug
      ? await resolveMemberId(db, input.currentLordSlug)
      : undefined,
    status: input.status,
    isGreatHouse: input.isGreatHouse,
    summary: input.summary,
    history: input.history,
    bannerPath: input.bannerPath,
    framePath: input.framePath,
  };

  const existing = await db.query.house.findFirst({
    where: eq(house.slug, input.slug),
    columns: { id: true },
  });
  if (existing) {
    const [record] = await db
      .update(house)
      .set(values)
      .where(eq(house.id, existing.id))
      .returning();
    return { status: "updated", record: record! };
  }
  const [record] = await db.insert(house).values(values).returning();
  return { status: "created", record: record! };
}

export type AddHouseRelationInput = {
  houseASlug: string;
  houseBSlug: string;
  type: HouseRelationType;
  startYear?: number | null;
  endYear?: number | null;
  isCurrent?: boolean;
  description?: string | null;
};

export async function addHouseRelation(
  db: Db,
  input: AddHouseRelationInput,
): Promise<LinkOutcome<HouseRelation>> {
  const houseAId = await resolveHouseId(db, input.houseASlug);
  const houseBId = await resolveHouseId(db, input.houseBSlug);

  const existing = await db.query.houseRelation.findFirst({
    where: and(
      eq(houseRelation.type, input.type),
      or(
        and(eq(houseRelation.houseAId, houseAId), eq(houseRelation.houseBId, houseBId)),
        and(eq(houseRelation.houseAId, houseBId), eq(houseRelation.houseBId, houseAId)),
      ),
    ),
  });
  if (existing) return { status: "exists", record: existing };

  const [record] = await db
    .insert(houseRelation)
    .values({
      houseAId,
      houseBId,
      type: input.type,
      startYear: input.startYear,
      endYear: input.endYear,
      isCurrent: input.isCurrent,
      description: input.description,
    })
    .returning();
  return { status: "created", record: record! };
}
