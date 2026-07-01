import { and, eq, isNull } from "drizzle-orm";

import type { Db } from "../index";
import { event, eventParticipant } from "../schema/events";
import type { EventParticipantRole, EventType } from "../schema/events";
import {
  resolveBattleId,
  resolveEventId,
  resolveHouseId,
  resolveLocationId,
  resolveMemberId,
  resolveWarId,
} from "./resolve";
import type { LinkOutcome, UpsertOutcome } from "./types";

export type Event = typeof event.$inferSelect;
export type EventParticipant = typeof eventParticipant.$inferSelect;

export type UpsertEventInput = {
  slug: string;
  name: string;
  type?: EventType;
  year?: number | null;
  endYear?: number | null;
  locationSlug?: string;
  warSlug?: string;
  battleSlug?: string;
  description?: string | null;
};

export async function upsertEvent(db: Db, input: UpsertEventInput): Promise<UpsertOutcome<Event>> {
  const values = {
    slug: input.slug,
    name: input.name,
    type: input.type,
    year: input.year,
    endYear: input.endYear,
    locationId: input.locationSlug ? await resolveLocationId(db, input.locationSlug) : undefined,
    warId: input.warSlug ? await resolveWarId(db, input.warSlug) : undefined,
    battleId: input.battleSlug ? await resolveBattleId(db, input.battleSlug) : undefined,
    description: input.description,
  };

  const existing = await db.query.event.findFirst({
    where: eq(event.slug, input.slug),
    columns: { id: true },
  });
  if (existing) {
    const [record] = await db
      .update(event)
      .set(values)
      .where(eq(event.id, existing.id))
      .returning();
    return { status: "updated", record: record! };
  }
  const [record] = await db.insert(event).values(values).returning();
  return { status: "created", record: record! };
}

export type AddEventParticipantInput = {
  eventSlug: string;
  memberSlug?: string;
  houseSlug?: string;
  role?: EventParticipantRole;
  notes?: string | null;
};

export async function addEventParticipant(
  db: Db,
  input: AddEventParticipantInput,
): Promise<LinkOutcome<EventParticipant>> {
  const eventId = await resolveEventId(db, input.eventSlug);
  const memberId = input.memberSlug ? await resolveMemberId(db, input.memberSlug) : null;
  const houseId = input.houseSlug ? await resolveHouseId(db, input.houseSlug) : null;
  if (memberId === null && houseId === null) {
    throw new Error("An event participant needs at least a memberSlug or a houseSlug.");
  }

  const existing = await db.query.eventParticipant.findFirst({
    where: and(
      eq(eventParticipant.eventId, eventId),
      memberId === null
        ? isNull(eventParticipant.memberId)
        : eq(eventParticipant.memberId, memberId),
      houseId === null ? isNull(eventParticipant.houseId) : eq(eventParticipant.houseId, houseId),
    ),
  });
  if (existing) return { status: "exists", record: existing };

  const [record] = await db
    .insert(eventParticipant)
    .values({
      eventId,
      memberId,
      houseId,
      role: input.role,
      notes: input.notes,
    })
    .returning();
  return { status: "created", record: record! };
}
