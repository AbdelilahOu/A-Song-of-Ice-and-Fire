import { z } from "zod";

import { publicProcedure } from "../index";

const timelineMemberColumns = {
  id: true,
  slug: true,
  name: true,
  fullName: true,
  surname: true,
  epithet: true,
  gender: true,
  status: true,
  bornYear: true,
  diedYear: true,
  portraitPath: true,
  houseId: true,
} as const;

const timelineHouseColumns = {
  slug: true,
  name: true,
  sigilColors: true,
} as const;

export const timelineRouter = {
  // Everything that can be placed on an absolute-year axis: members with a
  // known birth year, plus the major dated events. Powers the /timeline canvas.
  all: publicProcedure
    .input(z.object({ slug: z.string().nullable().optional() }).optional())
    .handler(async ({ context, input }) => {
      const { db } = context;

      const houseSlug = input?.slug ?? null;
      const house = houseSlug
        ? await db.query.house.findFirst({
            where: (h, { eq }) => eq(h.slug, houseSlug),
            columns: { id: true },
          })
        : null;
      const members = await db.query.member.findMany({
        where:
          houseSlug && !house
            ? (m, { eq }) => eq(m.id, -1)
            : house
              ? (m, { eq }) => eq(m.houseId, house.id)
              : undefined,
        columns: timelineMemberColumns,
        with: { house: { columns: timelineHouseColumns } },
        orderBy: (m, { asc }) => [asc(m.bornYear)],
      });

      const events = await db.query.event.findMany({
        columns: {
          id: true,
          slug: true,
          name: true,
          type: true,
          year: true,
          endYear: true,
          description: true,
        },
        orderBy: (e, { asc }) => [asc(e.year)],
      });

      const wars = await db.query.war.findMany({
        columns: {
          id: true,
          slug: true,
          name: true,
          startYear: true,
          endYear: true,
          description: true,
        },
        orderBy: (w, { asc }) => [asc(w.startYear)],
      });

      return {
        members: members.filter((m) => m.bornYear != null),
        events: events.filter((e) => e.year != null),
        wars: wars.filter((w) => w.startYear != null),
      };
    }),
};
