import { and, eq, or } from "drizzle-orm";

import type { Db } from "../index";
import { death } from "../schema/events";
import { marriage, member, memberAllegiance, memberRelation, memberTitle } from "../schema/members";
import type {
  AllegianceRole,
  Gender,
  MarriageStatus,
  MemberRelationType,
  MemberStatus,
} from "../schema/members";
import { resolveBattleId, resolveHouseId, resolveLocationId, resolveMemberId } from "./resolve";
import type { LinkOutcome, UpsertOutcome } from "./types";

export type Member = typeof member.$inferSelect;
export type MemberTitle = typeof memberTitle.$inferSelect;
export type Marriage = typeof marriage.$inferSelect;
export type MemberRelation = typeof memberRelation.$inferSelect;
export type MemberAllegiance = typeof memberAllegiance.$inferSelect;
export type Death = typeof death.$inferSelect;

export type UpsertMemberInput = {
  slug: string;
  name: string;
  fullName?: string | null;
  surname?: string | null;
  epithet?: string | null;
  houseSlug?: string;
  fatherSlug?: string;
  motherSlug?: string;
  gender?: Gender;
  status?: MemberStatus;
  isBastard?: boolean;
  isLegitimized?: boolean;
  bornYear?: number | null;
  diedYear?: number | null;
  culture?: string | null;
  portraitPath?: string | null;
  bio?: string | null;
  notableFor?: string | null;
};

export async function upsertMember(
  db: Db,
  input: UpsertMemberInput,
): Promise<UpsertOutcome<Member>> {
  const values = {
    slug: input.slug,
    name: input.name,
    fullName: input.fullName,
    surname: input.surname,
    epithet: input.epithet,
    houseId: input.houseSlug ? await resolveHouseId(db, input.houseSlug) : undefined,
    fatherId: input.fatherSlug ? await resolveMemberId(db, input.fatherSlug) : undefined,
    motherId: input.motherSlug ? await resolveMemberId(db, input.motherSlug) : undefined,
    gender: input.gender,
    status: input.status,
    isBastard: input.isBastard,
    isLegitimized: input.isLegitimized,
    bornYear: input.bornYear,
    diedYear: input.diedYear,
    culture: input.culture,
    portraitPath: input.portraitPath,
    bio: input.bio,
    notableFor: input.notableFor,
  };

  const existing = await db.query.member.findFirst({
    where: eq(member.slug, input.slug),
    columns: { id: true },
  });
  if (existing) {
    const [record] = await db
      .update(member)
      .set(values)
      .where(eq(member.id, existing.id))
      .returning();
    return { status: "updated", record: record! };
  }
  const [record] = await db.insert(member).values(values).returning();
  return { status: "created", record: record! };
}

export type AddTitleInput = {
  memberSlug: string;
  title: string;
  startYear?: number | null;
  endYear?: number | null;
  isCurrent?: boolean;
};

export async function addMemberTitle(
  db: Db,
  input: AddTitleInput,
): Promise<LinkOutcome<MemberTitle>> {
  const memberId = await resolveMemberId(db, input.memberSlug);
  const existing = await db.query.memberTitle.findFirst({
    where: and(eq(memberTitle.memberId, memberId), eq(memberTitle.title, input.title)),
  });
  if (existing) return { status: "exists", record: existing };

  const [record] = await db
    .insert(memberTitle)
    .values({
      memberId,
      title: input.title,
      startYear: input.startYear,
      endYear: input.endYear,
      isCurrent: input.isCurrent,
    })
    .returning();
  return { status: "created", record: record! };
}

export type AddMarriageInput = {
  spouseASlug: string;
  spouseBSlug: string;
  status?: MarriageStatus;
  startYear?: number | null;
  endYear?: number | null;
  isSecret?: boolean;
  notes?: string | null;
};

export async function addMarriage(db: Db, input: AddMarriageInput): Promise<LinkOutcome<Marriage>> {
  const spouseAId = await resolveMemberId(db, input.spouseASlug);
  const spouseBId = await resolveMemberId(db, input.spouseBSlug);

  const existing = await db.query.marriage.findFirst({
    where: or(
      and(eq(marriage.spouseAId, spouseAId), eq(marriage.spouseBId, spouseBId)),
      and(eq(marriage.spouseAId, spouseBId), eq(marriage.spouseBId, spouseAId)),
    ),
  });
  if (existing) return { status: "exists", record: existing };

  const [record] = await db
    .insert(marriage)
    .values({
      spouseAId,
      spouseBId,
      status: input.status,
      startYear: input.startYear,
      endYear: input.endYear,
      isSecret: input.isSecret,
      notes: input.notes,
    })
    .returning();
  return { status: "created", record: record! };
}

export type AddMemberRelationInput = {
  fromSlug: string;
  toSlug: string;
  type: MemberRelationType;
  notes?: string | null;
};

export async function addMemberRelation(
  db: Db,
  input: AddMemberRelationInput,
): Promise<LinkOutcome<MemberRelation>> {
  const fromMemberId = await resolveMemberId(db, input.fromSlug);
  const toMemberId = await resolveMemberId(db, input.toSlug);

  const existing = await db.query.memberRelation.findFirst({
    where: and(
      eq(memberRelation.fromMemberId, fromMemberId),
      eq(memberRelation.toMemberId, toMemberId),
      eq(memberRelation.type, input.type),
    ),
  });
  if (existing) return { status: "exists", record: existing };

  const [record] = await db
    .insert(memberRelation)
    .values({
      fromMemberId,
      toMemberId,
      type: input.type,
      notes: input.notes,
    })
    .returning();
  return { status: "created", record: record! };
}

export type AddAllegianceInput = {
  memberSlug: string;
  houseSlug: string;
  role?: AllegianceRole;
  isCurrent?: boolean;
  startYear?: number | null;
  endYear?: number | null;
  notes?: string | null;
};

export async function addMemberAllegiance(
  db: Db,
  input: AddAllegianceInput,
): Promise<LinkOutcome<MemberAllegiance>> {
  const memberId = await resolveMemberId(db, input.memberSlug);
  const houseId = await resolveHouseId(db, input.houseSlug);
  const role = input.role ?? "member";

  const existing = await db.query.memberAllegiance.findFirst({
    where: and(
      eq(memberAllegiance.memberId, memberId),
      eq(memberAllegiance.houseId, houseId),
      eq(memberAllegiance.role, role),
    ),
  });
  if (existing) return { status: "exists", record: existing };

  const [record] = await db
    .insert(memberAllegiance)
    .values({
      memberId,
      houseId,
      role,
      isCurrent: input.isCurrent,
      startYear: input.startYear,
      endYear: input.endYear,
      notes: input.notes,
    })
    .returning();
  return { status: "created", record: record! };
}

export type RecordDeathInput = {
  memberSlug: string;
  year?: number | null;
  locationSlug?: string;
  cause?: string | null;
  killerSlug?: string;
  battleSlug?: string;
  description?: string | null;
  isConfirmed?: boolean;
};

export async function recordDeath(db: Db, input: RecordDeathInput): Promise<UpsertOutcome<Death>> {
  const memberId = await resolveMemberId(db, input.memberSlug);
  const values = {
    memberId,
    year: input.year,
    locationId: input.locationSlug ? await resolveLocationId(db, input.locationSlug) : undefined,
    cause: input.cause,
    killerId: input.killerSlug ? await resolveMemberId(db, input.killerSlug) : undefined,
    battleId: input.battleSlug ? await resolveBattleId(db, input.battleSlug) : undefined,
    description: input.description,
    isConfirmed: input.isConfirmed,
  };

  const existing = await db.query.death.findFirst({
    where: eq(death.memberId, memberId),
    columns: { id: true },
  });
  if (existing) {
    const [record] = await db
      .update(death)
      .set(values)
      .where(eq(death.id, existing.id))
      .returning();
    return { status: "updated", record: record! };
  }
  const [record] = await db.insert(death).values(values).returning();
  return { status: "created", record: record! };
}
