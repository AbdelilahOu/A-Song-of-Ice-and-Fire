import { eq } from "drizzle-orm";

import type { Db } from "../index";
import { location } from "../schema/locations";
import type { LocationType } from "../schema/locations";
import { resolveHouseId } from "./resolve";
import type { UpsertOutcome } from "./types";

export type Location = typeof location.$inferSelect;

export type UpsertLocationInput = {
  slug: string;
  name: string;
  type?: LocationType;
  region?: string | null;
  controllingHouseSlug?: string;
  description?: string | null;
};

export async function upsertLocation(
  db: Db,
  input: UpsertLocationInput,
): Promise<UpsertOutcome<Location>> {
  const values = {
    slug: input.slug,
    name: input.name,
    type: input.type,
    region: input.region,
    controllingHouseId: input.controllingHouseSlug
      ? await resolveHouseId(db, input.controllingHouseSlug)
      : undefined,
    description: input.description,
  };

  const existing = await db.query.location.findFirst({
    where: eq(location.slug, input.slug),
    columns: { id: true },
  });
  if (existing) {
    const [record] = await db
      .update(location)
      .set(values)
      .where(eq(location.id, existing.id))
      .returning();
    return { status: "updated", record: record! };
  }
  const [record] = await db.insert(location).values(values).returning();
  return { status: "created", record: record! };
}
