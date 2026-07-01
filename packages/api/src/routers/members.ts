import { z } from "zod";

import { publicProcedure } from "../index";

const memberCardColumns = {
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
} as const;

export const membersRouter = {
  // Full detail for one member: house, parents, children, marriages, titles,
  // death, and allegiances — everything the detail dialog needs.
  getBySlug: publicProcedure
    .input(z.object({ slug: z.string() }))
    .handler(async ({ context, input }) => {
      return context.db.query.member.findFirst({
        where: (member, { eq }) => eq(member.slug, input.slug),
        with: {
          house: {
            columns: {
              id: true,
              slug: true,
              name: true,
              words: true,
              bannerPath: true,
              framePath: true,
              sigilColors: true,
            },
          },
          father: { columns: memberCardColumns },
          mother: { columns: memberCardColumns },
          childrenAsFather: { columns: memberCardColumns },
          childrenAsMother: { columns: memberCardColumns },
          titles: {
            orderBy: (title, { asc }) => [asc(title.startYear)],
          },
          marriagesAsA: { with: { spouseB: { columns: memberCardColumns } } },
          marriagesAsB: { with: { spouseA: { columns: memberCardColumns } } },
          allegiances: { with: { house: { columns: { slug: true, name: true } } } },
          death: {
            with: {
              killer: { columns: memberCardColumns },
              location: { columns: { slug: true, name: true } },
              battle: { columns: { slug: true, name: true } },
            },
          },
        },
      });
    }),
};
