import type { AppRouterClient } from "@GOT-familly-tree/api/routers/index";

import { displayName } from "./format";

type Member = NonNullable<Awaited<ReturnType<AppRouterClient["members"]["getBySlug"]>>>;
type Dragon = NonNullable<Awaited<ReturnType<AppRouterClient["dragons"]["getBySlug"]>>>;

export type LifeEventKind =
  | "birth"
  | "title"
  | "marriage"
  | "dragon"
  | "event"
  | "achievement"
  | "death";

export type LifeEvent = {
  year: number;
  label: string;
  detail?: string | null;
  kind: LifeEventKind;
};

// When several things happen in the same year, order them by life-stage so the
// timeline reads naturally (born before crowned before wed before died).
const KIND_ORDER: Record<LifeEventKind, number> = {
  birth: 0,
  title: 1,
  achievement: 2,
  dragon: 3,
  marriage: 4,
  event: 5,
  death: 6,
};

function sortEvents(events: LifeEvent[]): LifeEvent[] {
  return events.sort((a, b) => a.year - b.year || KIND_ORDER[a.kind] - KIND_ORDER[b.kind]);
}

export function buildMemberTimeline(member: Member): LifeEvent[] {
  const events: LifeEvent[] = [];

  if (member.bornYear != null) {
    events.push({ year: member.bornYear, label: "Born", kind: "birth" });
  }

  for (const t of member.titles) {
    if (t.startYear != null) {
      events.push({ year: t.startYear, label: `Styled ${t.title}`, kind: "title" });
    }
  }

  const spouses = [
    ...member.marriagesAsA.map((m) => ({ spouse: m.spouseB, marriage: m })),
    ...member.marriagesAsB.map((m) => ({ spouse: m.spouseA, marriage: m })),
  ];
  for (const { spouse, marriage } of spouses) {
    if (marriage.startYear != null) {
      events.push({
        year: marriage.startYear,
        label: `Wed ${displayName(spouse)}`,
        kind: "marriage",
      });
    }
  }

  for (const r of member.ridership) {
    if (r.startYear != null) {
      events.push({
        year: r.startYear,
        label: `Claimed ${r.dragon.name}`,
        detail: r.isNotable ? "Became a dragonrider" : null,
        kind: "dragon",
      });
    }
  }

  for (const a of member.achievements) {
    if (a.year != null) {
      events.push({ year: a.year, label: a.title, detail: a.description, kind: "achievement" });
    }
  }

  for (const p of member.eventParticipations) {
    if (p.event.year != null) {
      events.push({
        year: p.event.year,
        label: p.event.name,
        detail: p.role ? `Role: ${p.role}` : p.event.description,
        kind: "event",
      });
    }
  }

  const deathYear = member.death?.year ?? member.diedYear;
  if (deathYear != null) {
    events.push({
      year: deathYear,
      label: "Died",
      detail: member.death?.cause,
      kind: "death",
    });
  }

  return sortEvents(events);
}

export function buildDragonTimeline(dragon: Dragon): LifeEvent[] {
  const events: LifeEvent[] = [];

  if (dragon.bornYear != null) {
    events.push({ year: dragon.bornYear, label: "Hatched", kind: "birth" });
  }

  for (const r of dragon.riders) {
    if (r.startYear != null && r.member) {
      events.push({
        year: r.startYear,
        label: `Bonded with ${displayName(r.member)}`,
        kind: "dragon",
      });
    }
  }

  for (const a of dragon.achievements) {
    if (a.year != null) {
      events.push({ year: a.year, label: a.title, detail: a.description, kind: "achievement" });
    }
  }

  if (dragon.diedYear != null) {
    events.push({
      year: dragon.diedYear,
      label: dragon.killedInBattle ? `Slain at ${dragon.killedInBattle.name}` : "Died",
      detail: dragon.fate,
      kind: "death",
    });
  }

  return sortEvents(events);
}
