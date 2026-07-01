import { z } from "zod";

import { publicProcedure } from "../index";

const nodeColumns = {
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
  houseId: true,
  fatherId: true,
  motherId: true,
} as const;

const memberHouseCols = {
  slug: true,
  framePath: true,
  bannerPath: true,
} as const;

type NodeRow = {
  id: number;
  fatherId: number | null;
  motherId: number | null;
};

function buildEdges<T extends NodeRow>(
  nodes: T[],
  marriages: {
    spouseAId: number;
    spouseBId: number;
    status: string;
    isSecret: boolean;
  }[],
) {
  const nodeIds = new Set(nodes.map((n) => n.id));
  const parentEdges: { parentId: number; childId: number }[] = [];
  for (const n of nodes) {
    if (n.fatherId != null && nodeIds.has(n.fatherId)) {
      parentEdges.push({ parentId: n.fatherId, childId: n.id });
    }
    if (n.motherId != null && nodeIds.has(n.motherId)) {
      parentEdges.push({ parentId: n.motherId, childId: n.id });
    }
  }
  const marriageEdges = marriages
    .filter((m) => nodeIds.has(m.spouseAId) && nodeIds.has(m.spouseBId))
    .map((m) => ({
      spouseAId: m.spouseAId,
      spouseBId: m.spouseBId,
      status: m.status,
      isSecret: m.isSecret,
    }));
  return { parentEdges, marriageEdges };
}

export const treeRouter = {
  all: publicProcedure.handler(async ({ context }) => {
    const { db } = context;
    const rows = await db.query.member.findMany({
      columns: nodeColumns,
      with: { house: { columns: memberHouseCols } },
    });
    const marriages = await db.query.marriage.findMany();
    const nodes = rows.map((m) => ({ ...m, inHouse: true }));
    const { parentEdges, marriageEdges } = buildEdges(nodes, marriages);
    return { house: null, nodes, parentEdges, marriageEdges };
  }),

  overview: publicProcedure.handler(async ({ context }) => {
    const { db } = context;
    const houses = await db.query.house.findMany({
      columns: {
        id: true,
        slug: true,
        name: true,
        region: true,
        seat: true,
        words: true,
        sigilColors: true,
        bannerPath: true,
        isGreatHouse: true,
      },
      orderBy: (h, { asc }) => [asc(h.name)],
    });

    const relations = await db.query.houseRelation.findMany({
      columns: {
        id: true,
        houseAId: true,
        houseBId: true,
        type: true,
        description: true,
      },
    });

    const members = await db.query.member.findMany({
      columns: { houseId: true },
    });
    const counts = new Map<number, number>();
    for (const m of members) {
      if (m.houseId != null) counts.set(m.houseId, (counts.get(m.houseId) ?? 0) + 1);
    }

    return {
      houses: houses.map((h) => ({ ...h, memberCount: counts.get(h.id) ?? 0 })),
      relations,
    };
  }),

  byHouse: publicProcedure
    .input(z.object({ slug: z.string() }))
    .handler(async ({ context, input }) => {
      const { db } = context;

      const house = await db.query.house.findFirst({
        where: (h, { eq }) => eq(h.slug, input.slug),
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
        },
      });
      if (!house) return null;

      const houseMembers = await db.query.member.findMany({
        where: (m, { eq }) => eq(m.houseId, house.id),
        columns: nodeColumns,
        with: { house: { columns: memberHouseCols } },
      });

      const houseMemberIds = houseMembers.map((m) => m.id);

      const marriages = houseMemberIds.length
        ? await db.query.marriage.findMany({
            where: (mar, { inArray, or }) =>
              or(inArray(mar.spouseAId, houseMemberIds), inArray(mar.spouseBId, houseMemberIds)),
          })
        : [];

      const known = new Set(houseMemberIds);
      const relatedIds = new Set<number>();
      const consider = (id: number | null) => {
        if (id != null && !known.has(id)) relatedIds.add(id);
      };
      for (const m of houseMembers) {
        consider(m.fatherId);
        consider(m.motherId);
      }
      for (const mar of marriages) {
        consider(mar.spouseAId);
        consider(mar.spouseBId);
      }

      const relatedMembers = relatedIds.size
        ? await db.query.member.findMany({
            where: (m, { inArray }) => inArray(m.id, Array.from(relatedIds)),
            columns: nodeColumns,
            with: { house: { columns: memberHouseCols } },
          })
        : [];

      const nodes = [
        ...houseMembers.map((m) => ({ ...m, inHouse: true })),
        ...relatedMembers.map((m) => ({ ...m, inHouse: false })),
      ];

      const { parentEdges, marriageEdges } = buildEdges(nodes, marriages);

      return { house, nodes, parentEdges, marriageEdges };
    }),
};
