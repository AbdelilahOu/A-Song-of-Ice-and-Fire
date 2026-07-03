import { and, eq } from "drizzle-orm";

import type { Db } from "../index";
import { dragon, dragonRider } from "../schema/dragons";
import type { DragonSize, DragonStatus } from "../schema/dragons";
import { resolveBattleId, resolveDragonId, resolveMemberId } from "./resolve";
import type { LinkOutcome, UpsertOutcome } from "./types";

export type Dragon = typeof dragon.$inferSelect;
export type DragonRider = typeof dragonRider.$inferSelect;

export type UpsertDragonInput = {
  slug: string;
  name: string;
  epithet?: string | null;
  status?: DragonStatus;
  size?: DragonSize;
  color?: string | null;
  bornYear?: number | null;
  diedYear?: number | null;
  notableRiderSlug?: string;
  killedInBattleSlug?: string;
  description?: string | null;
  notableFor?: string | null;
  fate?: string | null;
};

export async function upsertDragon(
  db: Db,
  input: UpsertDragonInput,
): Promise<UpsertOutcome<Dragon>> {
  const values = {
    slug: input.slug,
    name: input.name,
    epithet: input.epithet,
    status: input.status,
    size: input.size,
    color: input.color,
    bornYear: input.bornYear,
    diedYear: input.diedYear,
    notableRiderId: input.notableRiderSlug
      ? await resolveMemberId(db, input.notableRiderSlug)
      : undefined,
    killedInBattleId: input.killedInBattleSlug
      ? await resolveBattleId(db, input.killedInBattleSlug)
      : undefined,
    description: input.description,
    notableFor: input.notableFor,
    fate: input.fate,
  };

  const existing = await db.query.dragon.findFirst({
    where: eq(dragon.slug, input.slug),
    columns: { id: true },
  });
  if (existing) {
    const [record] = await db
      .update(dragon)
      .set(values)
      .where(eq(dragon.id, existing.id))
      .returning();
    return { status: "updated", record: record! };
  }
  const [record] = await db.insert(dragon).values(values).returning();
  return { status: "created", record: record! };
}

export type AddDragonRiderInput = {
  dragonSlug: string;
  memberSlug: string;
  startYear?: number | null;
  endYear?: number | null;
  isNotable?: boolean;
  notes?: string | null;
};

export async function addDragonRider(
  db: Db,
  input: AddDragonRiderInput,
): Promise<LinkOutcome<DragonRider>> {
  const dragonId = await resolveDragonId(db, input.dragonSlug);
  const memberId = await resolveMemberId(db, input.memberSlug);

  const existing = await db.query.dragonRider.findFirst({
    where: and(eq(dragonRider.dragonId, dragonId), eq(dragonRider.memberId, memberId)),
  });
  if (existing) return { status: "exists", record: existing };

  const [record] = await db
    .insert(dragonRider)
    .values({
      dragonId,
      memberId,
      startYear: input.startYear,
      endYear: input.endYear,
      isNotable: input.isNotable,
      notes: input.notes,
    })
    .returning();
  return { status: "created", record: record! };
}
