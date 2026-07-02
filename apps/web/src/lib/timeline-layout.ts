// Dependency-free layout for the chronological saga timeline. Places every
// member as a lifespan bar on an absolute-year axis (negative = Before Conquest,
// positive = After Conquest), grouped into per-house swimlanes, and lays the
// major wars/events out as markers along the same axis.

export type TimelineMemberInput = {
  id: number;
  slug: string;
  name: string;
  fullName: string | null;
  surname: string | null;
  epithet: string | null;
  gender: "male" | "female" | "unknown";
  status: "alive" | "dead" | "unknown";
  bornYear: number | null;
  diedYear: number | null;
  portraitPath: string | null;
  houseId: number | null;
  house: { slug: string; name: string; sigilColors: string | null } | null;
};

export type TimelineEventInput = {
  id: number;
  slug: string;
  name: string;
  type: string;
  year: number | null;
  endYear: number | null;
  description: string | null;
};

export type TimelineWarInput = {
  id: number;
  slug: string;
  name: string;
  startYear: number | null;
  endYear: number | null;
  description: string | null;
};

export type MemberBar = {
  member: TimelineMemberInput;
  x: number;
  y: number;
  w: number;
  h: number;
  isAlive: boolean;
  openEnded: boolean; // no known death year and not marked alive
  color: string;
};

export type BandRow = {
  key: string;
  name: string;
  color: string;
  y: number;
  height: number;
};

export type YearTick = { year: number; x: number; label: string };

export type WarSpan = {
  war: TimelineWarInput;
  x: number;
  w: number;
};

export type EventMarker = {
  event: TimelineEventInput;
  x: number;
};

export type TimelineLayout = {
  bars: MemberBar[];
  bands: BandRow[];
  ticks: YearTick[];
  wars: WarSpan[];
  events: EventMarker[];
  width: number;
  height: number;
  minYear: number;
  maxYear: number;
  axisH: number;
  laneStartX: number;
};

export const PX_PER_YEAR = 9;
export const LANE_H = 26;
export const BAR_H = 18;
const BAND_LABEL_W = 132;
const BAND_GAP = 10;
const PAD_X = 40;
export const AXIS_H = 46;
const TOP_PAD = 16;
const MIN_BAR_W = 30;

// House accent colors — cold-leaning where possible to stay in the Stark theme,
// but distinct enough to read at a glance across the swimlanes.
const HOUSE_COLORS: Record<string, string> = {
  stark: "#9fb2bf",
  targaryen: "#c1584f",
  lannister: "#c2a24a",
  baratheon: "#c8a84e",
  tully: "#6f93b6",
  arryn: "#8fb7db",
  tyrell: "#6fae72",
  martell: "#d08a4a",
  greyjoy: "#8894a0",
};
const NO_HOUSE_COLOR = "#5f6b74";

function houseColor(slug: string | null | undefined): string {
  if (!slug) return NO_HOUSE_COLOR;
  return HOUSE_COLORS[slug] ?? "#7f8a93";
}

// Round a year down/up to a "nice" tick step so the axis labels stay readable.
function niceStep(span: number): number {
  if (span <= 120) return 10;
  if (span <= 300) return 25;
  if (span <= 600) return 50;
  return 100;
}

export function layoutTimeline(
  members: TimelineMemberInput[],
  events: TimelineEventInput[],
  wars: TimelineWarInput[],
): TimelineLayout {
  const placeable = members.filter((m) => m.bornYear != null);

  let minYear = Infinity;
  let maxYear = -Infinity;
  for (const m of placeable) {
    minYear = Math.min(minYear, m.bornYear!);
    maxYear = Math.max(maxYear, m.diedYear ?? m.bornYear!);
  }
  for (const e of events) {
    if (e.year != null) {
      minYear = Math.min(minYear, e.year);
      maxYear = Math.max(maxYear, e.endYear ?? e.year);
    }
  }
  for (const w of wars) {
    if (w.startYear != null) {
      minYear = Math.min(minYear, w.startYear);
      maxYear = Math.max(maxYear, w.endYear ?? w.startYear);
    }
  }
  if (!isFinite(minYear)) {
    minYear = 0;
    maxYear = 0;
  }
  // Breathing room on each end.
  minYear -= 5;
  maxYear += 5;

  const laneStartX = PAD_X + BAND_LABEL_W;
  const xOf = (year: number) => laneStartX + (year - minYear) * PX_PER_YEAR;

  // Group members into house bands, ordered by each house's earliest birth so
  // the oldest lineages sit at the top. Members with no house share one band.
  const groups = new Map<string, TimelineMemberInput[]>();
  for (const m of placeable) {
    const key = m.house?.slug ?? "__none__";
    const arr = groups.get(key) ?? [];
    arr.push(m);
    groups.set(key, arr);
  }

  const groupOrder = [...groups.entries()].sort((a, b) => {
    const ay = Math.min(...a[1].map((m) => m.bornYear!));
    const by = Math.min(...b[1].map((m) => m.bornYear!));
    return ay - by;
  });

  const bars: MemberBar[] = [];
  const bands: BandRow[] = [];
  let cursorY = AXIS_H + TOP_PAD;

  for (const [key, groupMembers] of groupOrder) {
    const sample = groupMembers.find((m) => m.house);
    const name = sample?.house?.name ?? "Unaligned";
    const color = houseColor(sample?.house?.slug ?? null);

    // Greedy interval packing into lanes within the band.
    const sorted = [...groupMembers].sort((a, b) => a.bornYear! - b.bornYear!);
    const laneEndX: number[] = [];
    const bandStartY = cursorY;

    for (const m of sorted) {
      const isAlive = m.status === "alive";
      const openEnded = m.diedYear == null && !isAlive;
      const endYear = m.diedYear ?? maxYear;
      const x = xOf(m.bornYear!);
      const rawW = (endYear - m.bornYear!) * PX_PER_YEAR;
      const w = Math.max(MIN_BAR_W, rawW);

      let lane = laneEndX.findIndex((end) => x >= end + 6);
      if (lane === -1) {
        lane = laneEndX.length;
        laneEndX.push(0);
      }
      laneEndX[lane] = x + w;

      const y = bandStartY + lane * LANE_H + (LANE_H - BAR_H) / 2;
      bars.push({ member: m, x, y, w, h: BAR_H, isAlive, openEnded, color });
    }

    const laneCount = Math.max(1, laneEndX.length);
    const height = laneCount * LANE_H;
    bands.push({ key, name, color, y: bandStartY, height });
    cursorY = bandStartY + height + BAND_GAP;
  }

  const height = Math.max(cursorY + 20, AXIS_H + 120);

  // Year ticks.
  const span = maxYear - minYear;
  const step = niceStep(span);
  const ticks: YearTick[] = [];
  const firstTick = Math.ceil(minYear / step) * step;
  for (let y = firstTick; y <= maxYear; y += step) {
    ticks.push({
      year: y,
      x: xOf(y),
      label: y < 0 ? `${-y} BC` : y === 0 ? "0" : `${y} AC`,
    });
  }

  const warSpans: WarSpan[] = wars
    .filter((w) => w.startYear != null)
    .map((w) => {
      const x = xOf(w.startYear!);
      const end = w.endYear ?? w.startYear!;
      return { war: w, x, w: Math.max(4, (end - w.startYear!) * PX_PER_YEAR) };
    });

  const eventMarkers: EventMarker[] = events
    .filter((e) => e.year != null)
    .map((e) => ({ event: e, x: xOf(e.year!) }));

  const width = xOf(maxYear) + PAD_X;

  return {
    bars,
    bands,
    ticks,
    wars: warSpans,
    events: eventMarkers,
    width,
    height,
    minYear,
    maxYear,
    axisH: AXIS_H,
    laneStartX,
  };
}
