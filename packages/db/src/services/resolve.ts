import { eq } from "drizzle-orm";

import type { Db } from "../index";
import { battle, war } from "../schema/conflicts";
import { dragon } from "../schema/dragons";
import { event } from "../schema/events";
import { house } from "../schema/houses";
import { location } from "../schema/locations";
import { member } from "../schema/members";

export async function resolveHouseId(db: Db, slug: string): Promise<number> {
  const row = await db.query.house.findFirst({
    where: eq(house.slug, slug),
    columns: { id: true },
  });
  if (!row) throw new Error(`House "${slug}" does not exist. Create the house first.`);
  return row.id;
}

export async function resolveMemberId(db: Db, slug: string): Promise<number> {
  const row = await db.query.member.findFirst({
    where: eq(member.slug, slug),
    columns: { id: true },
  });
  if (!row) throw new Error(`Member "${slug}" does not exist. Create the member first.`);
  return row.id;
}

export async function resolveLocationId(db: Db, slug: string): Promise<number> {
  const row = await db.query.location.findFirst({
    where: eq(location.slug, slug),
    columns: { id: true },
  });
  if (!row) throw new Error(`Location "${slug}" does not exist. Create the location first.`);
  return row.id;
}

export async function resolveWarId(db: Db, slug: string): Promise<number> {
  const row = await db.query.war.findFirst({
    where: eq(war.slug, slug),
    columns: { id: true },
  });
  if (!row) throw new Error(`War "${slug}" does not exist. Create the war first.`);
  return row.id;
}

export async function resolveBattleId(db: Db, slug: string): Promise<number> {
  const row = await db.query.battle.findFirst({
    where: eq(battle.slug, slug),
    columns: { id: true },
  });
  if (!row) throw new Error(`Battle "${slug}" does not exist. Create the battle first.`);
  return row.id;
}

export async function resolveDragonId(db: Db, slug: string): Promise<number> {
  const row = await db.query.dragon.findFirst({
    where: eq(dragon.slug, slug),
    columns: { id: true },
  });
  if (!row) throw new Error(`Dragon "${slug}" does not exist. Create the dragon first.`);
  return row.id;
}

export async function resolveEventId(db: Db, slug: string): Promise<number> {
  const row = await db.query.event.findFirst({
    where: eq(event.slug, slug),
    columns: { id: true },
  });
  if (!row) throw new Error(`Event "${slug}" does not exist. Create the event first.`);
  return row.id;
}
