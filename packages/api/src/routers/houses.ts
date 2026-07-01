import { z } from "zod";

import { publicProcedure } from "../index";

export const housesRouter = {
  list: publicProcedure.handler(async ({ context }) => {
    return context.db.query.house.findMany({
      columns: {
        id: true,
        slug: true,
        name: true,
        fullName: true,
        words: true,
        region: true,
        seat: true,
        sigilColors: true,
        bannerPath: true,
        framePath: true,
        isGreatHouse: true,
      },
      orderBy: (house, { asc }) => [asc(house.name)],
    });
  }),

  getBySlug: publicProcedure
    .input(z.object({ slug: z.string() }))
    .handler(async ({ context, input }) => {
      return context.db.query.house.findFirst({
        where: (house, { eq }) => eq(house.slug, input.slug),
        with: {
          members: {
            columns: {
              id: true,
              slug: true,
              name: true,
              fullName: true,
              surname: true,
              epithet: true,
              gender: true,
              status: true,
              isBastard: true,
              bornYear: true,
              diedYear: true,
              portraitPath: true,
              notableFor: true,
            },
            orderBy: (member, { asc }) => [asc(member.bornYear)],
          },
          relationsA: { with: { houseB: true } },
          relationsB: { with: { houseA: true } },
        },
      });
    }),
};
