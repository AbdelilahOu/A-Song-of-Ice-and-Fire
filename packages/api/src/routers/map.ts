import { z } from "zod";

import { publicProcedure } from "../index";

export const mapRouter = {
  // Events tied to a house, for the map's house-filtered event list. A house is
  // "related" to an event when: a house member participated, the house itself is
  // a participant, or the event happened at a location the house controls. Each
  // event carries its resolved location (directly, or via its battle) so the
  // client can place it on the map.
  eventsByHouse: publicProcedure
    .input(z.object({ slug: z.string() }))
    .handler(async ({ context, input }) => {
      const { db } = context;

      const house = await db.query.house.findFirst({
        where: (h, { eq }) => eq(h.slug, input.slug),
        columns: { id: true },
      });
      if (!house) return [];

      // Fetch broadly and join in JS to stay under D1's 100-parameter cap
      // (same approach as the tree router).
      const [events, participants, members, locations, battles] = await Promise.all([
        db.query.event.findMany({
          columns: {
            id: true,
            slug: true,
            name: true,
            type: true,
            year: true,
            endYear: true,
            description: true,
            locationId: true,
            battleId: true,
          },
          orderBy: (e, { asc }) => [asc(e.year)],
        }),
        db.query.eventParticipant.findMany({
          columns: { eventId: true, memberId: true, houseId: true },
        }),
        db.query.member.findMany({ columns: { id: true, houseId: true } }),
        db.query.location.findMany({
          columns: { id: true, slug: true, name: true, region: true, controllingHouseId: true },
        }),
        db.query.battle.findMany({ columns: { id: true, locationId: true } }),
      ]);

      const memberHouse = new Map(members.map((m) => [m.id, m.houseId]));
      const locationById = new Map(locations.map((l) => [l.id, l]));
      const battleLocation = new Map(battles.map((b) => [b.id, b.locationId]));

      const relatedEventIds = new Set<number>();
      for (const p of participants) {
        if (p.houseId === house.id) relatedEventIds.add(p.eventId);
        else if (p.memberId != null && memberHouse.get(p.memberId) === house.id) {
          relatedEventIds.add(p.eventId);
        }
      }
      for (const e of events) {
        const loc = e.locationId != null ? locationById.get(e.locationId) : undefined;
        if (loc?.controllingHouseId === house.id) relatedEventIds.add(e.id);
      }

      return events
        .filter((e) => relatedEventIds.has(e.id))
        .map((e) => {
          const locId =
            e.locationId ?? (e.battleId != null ? battleLocation.get(e.battleId) : null);
          const loc = locId != null ? locationById.get(locId) : undefined;
          return {
            id: e.id,
            slug: e.slug,
            name: e.name,
            type: e.type,
            year: e.year,
            endYear: e.endYear,
            description: e.description,
            location: loc ? { slug: loc.slug, name: loc.name, region: loc.region } : null,
          };
        });
    }),
};
