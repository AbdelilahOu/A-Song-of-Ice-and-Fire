import { z } from "zod";

import { publicProcedure } from "../index";

const riderColumns = {
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

export const dragonsRouter = {
  // Roster of all dragons, lightest columns, with the notable rider's house so
  // callers can group them (e.g. the Targaryen house page).
  list: publicProcedure.handler(async ({ context }) => {
    return context.db.query.dragon.findMany({
      columns: {
        id: true,
        slug: true,
        name: true,
        epithet: true,
        status: true,
        size: true,
        color: true,
        bornYear: true,
        diedYear: true,
        notableFor: true,
      },
      with: {
        notableRider: {
          columns: { slug: true, name: true, houseId: true },
          with: { house: { columns: { slug: true, name: true } } },
        },
      },
      orderBy: (dragon, { asc }) => [asc(dragon.name)],
    });
  }),

  getBySlug: publicProcedure
    .input(z.object({ slug: z.string() }))
    .handler(async ({ context, input }) => {
      return context.db.query.dragon.findFirst({
        where: (dragon, { eq }) => eq(dragon.slug, input.slug),
        with: {
          notableRider: {
            columns: riderColumns,
            with: { house: { columns: { slug: true, name: true, framePath: true } } },
          },
          killedInBattle: {
            columns: { slug: true, name: true, year: true },
            with: { war: { columns: { slug: true, name: true } } },
          },
          riders: {
            with: { member: { columns: riderColumns } },
            orderBy: (rider, { asc }) => [asc(rider.startYear)],
          },
          achievements: {
            orderBy: (achievement, { asc }) => [asc(achievement.sortOrder), asc(achievement.year)],
          },
        },
      });
    }),
};
