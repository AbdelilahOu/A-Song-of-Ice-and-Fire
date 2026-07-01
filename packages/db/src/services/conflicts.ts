import { and, eq, isNull } from "drizzle-orm";

import type { Db } from "../index";
import { battle, battleParticipant, war, warParticipant } from "../schema/conflicts";
import type { ParticipantRole } from "../schema/conflicts";
import {
  resolveBattleId,
  resolveHouseId,
  resolveLocationId,
  resolveMemberId,
  resolveWarId,
} from "./resolve";
import type { LinkOutcome, UpsertOutcome } from "./types";

export type War = typeof war.$inferSelect;
export type Battle = typeof battle.$inferSelect;
export type WarParticipant = typeof warParticipant.$inferSelect;
export type BattleParticipant = typeof battleParticipant.$inferSelect;

export type UpsertWarInput = {
  slug: string;
  name: string;
  startYear?: number | null;
  endYear?: number | null;
  description?: string | null;
  outcome?: string | null;
  victorHouseSlug?: string;
};

export async function upsertWar(db: Db, input: UpsertWarInput): Promise<UpsertOutcome<War>> {
  const values = {
    slug: input.slug,
    name: input.name,
    startYear: input.startYear,
    endYear: input.endYear,
    description: input.description,
    outcome: input.outcome,
    victorHouseId: input.victorHouseSlug
      ? await resolveHouseId(db, input.victorHouseSlug)
      : undefined,
  };

  const existing = await db.query.war.findFirst({
    where: eq(war.slug, input.slug),
    columns: { id: true },
  });
  if (existing) {
    const [record] = await db.update(war).set(values).where(eq(war.id, existing.id)).returning();
    return { status: "updated", record: record! };
  }
  const [record] = await db.insert(war).values(values).returning();
  return { status: "created", record: record! };
}

export type UpsertBattleInput = {
  slug: string;
  name: string;
  warSlug?: string;
  year?: number | null;
  locationSlug?: string;
  description?: string | null;
  outcome?: string | null;
  victorSide?: string | null;
};

export async function upsertBattle(
  db: Db,
  input: UpsertBattleInput,
): Promise<UpsertOutcome<Battle>> {
  const values = {
    slug: input.slug,
    name: input.name,
    warId: input.warSlug ? await resolveWarId(db, input.warSlug) : undefined,
    year: input.year,
    locationId: input.locationSlug ? await resolveLocationId(db, input.locationSlug) : undefined,
    description: input.description,
    outcome: input.outcome,
    victorSide: input.victorSide,
  };

  const existing = await db.query.battle.findFirst({
    where: eq(battle.slug, input.slug),
    columns: { id: true },
  });
  if (existing) {
    const [record] = await db
      .update(battle)
      .set(values)
      .where(eq(battle.id, existing.id))
      .returning();
    return { status: "updated", record: record! };
  }
  const [record] = await db.insert(battle).values(values).returning();
  return { status: "created", record: record! };
}

export type AddWarParticipantInput = {
  warSlug: string;
  houseSlug?: string;
  memberSlug?: string;
  side?: string | null;
  role?: ParticipantRole;
  outcome?: string | null;
};

export async function addWarParticipant(
  db: Db,
  input: AddWarParticipantInput,
): Promise<LinkOutcome<WarParticipant>> {
  const warId = await resolveWarId(db, input.warSlug);
  const houseId = input.houseSlug ? await resolveHouseId(db, input.houseSlug) : null;
  const memberId = input.memberSlug ? await resolveMemberId(db, input.memberSlug) : null;
  if (houseId === null && memberId === null) {
    throw new Error("A war participant needs at least a houseSlug or a memberSlug.");
  }

  const existing = await db.query.warParticipant.findFirst({
    where: and(
      eq(warParticipant.warId, warId),
      houseId === null ? isNull(warParticipant.houseId) : eq(warParticipant.houseId, houseId),
      memberId === null ? isNull(warParticipant.memberId) : eq(warParticipant.memberId, memberId),
    ),
  });
  if (existing) return { status: "exists", record: existing };

  const [record] = await db
    .insert(warParticipant)
    .values({
      warId,
      houseId,
      memberId,
      side: input.side,
      role: input.role,
      outcome: input.outcome,
    })
    .returning();
  return { status: "created", record: record! };
}

export type AddBattleParticipantInput = {
  battleSlug: string;
  houseSlug?: string;
  memberSlug?: string;
  side?: string | null;
  role?: ParticipantRole;
  wasCommander?: boolean;
  wasKilled?: boolean;
};

export async function addBattleParticipant(
  db: Db,
  input: AddBattleParticipantInput,
): Promise<LinkOutcome<BattleParticipant>> {
  const battleId = await resolveBattleId(db, input.battleSlug);
  const houseId = input.houseSlug ? await resolveHouseId(db, input.houseSlug) : null;
  const memberId = input.memberSlug ? await resolveMemberId(db, input.memberSlug) : null;
  if (houseId === null && memberId === null) {
    throw new Error("A battle participant needs at least a houseSlug or a memberSlug.");
  }

  const existing = await db.query.battleParticipant.findFirst({
    where: and(
      eq(battleParticipant.battleId, battleId),
      houseId === null ? isNull(battleParticipant.houseId) : eq(battleParticipant.houseId, houseId),
      memberId === null
        ? isNull(battleParticipant.memberId)
        : eq(battleParticipant.memberId, memberId),
    ),
  });
  if (existing) return { status: "exists", record: existing };

  const [record] = await db
    .insert(battleParticipant)
    .values({
      battleId,
      houseId,
      memberId,
      side: input.side,
      role: input.role,
      wasCommander: input.wasCommander,
      wasKilled: input.wasKilled,
    })
    .returning();
  return { status: "created", record: record! };
}
