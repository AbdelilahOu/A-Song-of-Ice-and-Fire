export type TreeNodeInput = {
  id: number;
  slug: string;
  name: string;
  fullName: string | null;
  surname: string | null;
  epithet: string | null;
  gender: "male" | "female" | "unknown";
  status: "alive" | "dead" | "unknown";
  isBastard: boolean;
  bornYear: number | null;
  diedYear: number | null;
  portraitPath: string | null;
  houseId: number | null;
  fatherId: number | null;
  motherId: number | null;
  inHouse: boolean;
  house: { slug: string; framePath: string | null; bannerPath: string | null } | null;
};

export type ParentEdgeInput = { parentId: number; childId: number };
export type MarriageEdgeInput = {
  spouseAId: number;
  spouseBId: number;
  status: string;
  isSecret: boolean;
};

export type PositionedNode = TreeNodeInput & {
  x: number;
  y: number;
  depth: number;
};

// "drop" links connect a child to the parent (or couple) it is laid out
// under; they can be drawn as right-angle elbows. "cross" links point to a
// parent placed elsewhere on the canvas and should be drawn as curves.
export type ParentLink = {
  fromX: number;
  fromY: number;
  toX: number;
  toY: number;
  kind: "drop" | "cross";
};

// "couple" links join two spouses placed side by side; "distant" links join
// spouses laid out in different units.
export type MarriageLink = {
  x1: number;
  y1: number;
  x2: number;
  y2: number;
  isSecret: boolean;
  kind: "couple" | "distant";
};

export type HouseGroup = {
  houseSlug: string | null;
  x: number;
  width: number;
};

export type LayoutResult = {
  nodes: PositionedNode[];
  parentLinks: ParentLink[];
  marriageLinks: MarriageLink[];
  groups: HouseGroup[];
  width: number;
  height: number;
};

export const FRAME_W = 116;
export const FRAME_H = 155;
export const NODE_W = 128;
export const NODE_H = 208;
const H_GAP = 30;
const V_GAP = 72;
const COUPLE_GAP = 26;
const PAD = 60;
const ROOT_GAP = H_GAP * 3;
const GROUP_GAP = 220;

// Horizontal extent of a subtree at each depth below the unit, relative to
// the unit's center. Packing siblings by these per-row extents (instead of a
// single bounding box) lets a narrow branch sit close to its siblings when
// their deeper rows do not actually collide.
type Shape = { left: number[]; right: number[] };

type Unit = {
  members: number[];
  children: Unit[];
  depth: number;
  centerX: number;
  childOffsets: number[];
  shape: Shape;
};

const coupleKey = (a: number, b: number) => (a < b ? `${a}-${b}` : `${b}-${a}`);

// Minimum shift that keeps `shape` clear of the accumulated contour by `gap`
// on every row both occupy. Rows the contour does not reach are free, so a
// short subtree can slide under a taller sibling's overhang.
function shiftToClear(accRight: number[], shape: Shape, gap: number): number {
  let dx = -Infinity;
  const depths = Math.min(accRight.length, shape.left.length);
  for (let d = 0; d < depths; d++) {
    dx = Math.max(dx, accRight[d] + gap - shape.left[d]);
  }
  return isFinite(dx) ? dx : 0;
}

function mergeContour(accLeft: number[], accRight: number[], shape: Shape, dx: number) {
  for (let d = 0; d < shape.left.length; d++) {
    if (d < accLeft.length) {
      accLeft[d] = Math.min(accLeft[d], shape.left[d] + dx);
      accRight[d] = Math.max(accRight[d], shape.right[d] + dx);
    } else {
      accLeft.push(shape.left[d] + dx);
      accRight.push(shape.right[d] + dx);
    }
  }
}

export function layoutTree(
  rawNodes: TreeNodeInput[],
  parentEdges: ParentEdgeInput[],
  marriageEdges: MarriageEdgeInput[],
): LayoutResult {
  const nodeById = new Map<number, TreeNodeInput>();
  for (const n of rawNodes) nodeById.set(n.id, n);

  const marriagesOf = new Map<number, number[]>();
  for (const m of marriageEdges) {
    if (!nodeById.has(m.spouseAId) || !nodeById.has(m.spouseBId)) continue;
    const a = marriagesOf.get(m.spouseAId);
    if (a) a.push(m.spouseBId);
    else marriagesOf.set(m.spouseAId, [m.spouseBId]);
    const b = marriagesOf.get(m.spouseBId);
    if (b) b.push(m.spouseAId);
    else marriagesOf.set(m.spouseBId, [m.spouseAId]);
  }

  // How many children each pair of parents shares; used to decide which
  // spouse a remarried member is placed next to.
  const coupleChildren = new Map<string, number>();
  for (const n of rawNodes) {
    if (n.fatherId != null && n.motherId != null) {
      const k = coupleKey(n.fatherId, n.motherId);
      coupleChildren.set(k, (coupleChildren.get(k) ?? 0) + 1);
    }
  }

  const parentsOf = new Map<number, number[]>();
  for (const e of parentEdges) {
    if (!nodeById.has(e.parentId) || !nodeById.has(e.childId)) continue;
    const arr = parentsOf.get(e.childId) ?? [];
    arr.push(e.parentId);
    parentsOf.set(e.childId, arr);
  }

  const unitOfMember = new Map<number, Unit>();
  const units: Unit[] = [];
  const bornYear = (id: number) => nodeById.get(id)?.bornYear ?? 9999;

  for (const n of rawNodes) {
    if (unitOfMember.has(n.id)) continue;
    let spouse: number | null = null;
    let bestShared = -1;
    for (const s of marriagesOf.get(n.id) ?? []) {
      if (unitOfMember.has(s)) continue;
      const shared = coupleChildren.get(coupleKey(n.id, s)) ?? 0;
      if (shared > bestShared) {
        bestShared = shared;
        spouse = s;
      }
    }
    const members = spouse != null ? [n.id, spouse] : [n.id];
    const unit: Unit = {
      members,
      children: [],
      depth: 0,
      centerX: 0,
      childOffsets: [],
      shape: { left: [], right: [] },
    };
    for (const m of members) unitOfMember.set(m, unit);
    units.push(unit);
  }

  const anchorParent = (c: TreeNodeInput, ps: number[]) => {
    const father = c.fatherId != null && ps.includes(c.fatherId) ? c.fatherId : null;
    return father ?? ps[0];
  };

  const parentOfUnit = new Map<Unit, Unit>();
  const childNodes = [...rawNodes].sort((a, b) => bornYear(a.id) - bornYear(b.id));
  for (const c of childNodes) {
    const ps = parentsOf.get(c.id);
    if (!ps || ps.length === 0) continue;
    const parentUnit = unitOfMember.get(anchorParent(c, ps));
    const childUnit = unitOfMember.get(c.id);
    if (!parentUnit || !childUnit || parentUnit === childUnit) continue;
    if (parentOfUnit.has(childUnit)) continue;
    parentOfUnit.set(childUnit, parentUnit);
    parentUnit.children.push(childUnit);
  }

  for (const u of units) {
    u.children.sort((a, b) => bornYear(a.members[0]) - bornYear(b.members[0]));
  }

  // Childless single members whose spouse is placed inside a tree are
  // "satellites": instead of floating at the top as roots of their own
  // house group, they are positioned next to their spouse on the same row.
  const roots = units.filter((u) => !parentOfUnit.has(u));
  const satellites: Unit[] = [];
  const treeRoots: Unit[] = [];
  for (const r of roots) {
    const spouses = r.members.length === 1 ? (marriagesOf.get(r.members[0]) ?? []) : [];
    if (r.children.length === 0 && spouses.length > 0) satellites.push(r);
    else treeRoots.push(r);
  }

  const houseKeyOf = (u: Unit) => nodeById.get(u.members[0])?.house?.slug ?? null;

  const rootsByHouse = new Map<string | null, Unit[]>();
  for (const r of treeRoots) {
    const k = houseKeyOf(r);
    const arr = rootsByHouse.get(k);
    if (arr) arr.push(r);
    else rootsByHouse.set(k, [r]);
  }
  const groupKeys = [...rootsByHouse.keys()].sort((a, b) => {
    if (a === null) return 1;
    if (b === null) return -1;
    return a.localeCompare(b);
  });

  const unitWidth = (u: Unit) => (u.members.length === 2 ? NODE_W * 2 + COUPLE_GAP : NODE_W);

  const positions = new Map<number, { x: number; y: number; depth: number }>();

  const placeMembers = (u: Unit) => {
    const y = u.depth * (NODE_H + V_GAP);
    if (u.members.length === 2) {
      const leftX = u.centerX - (NODE_W * 2 + COUPLE_GAP) / 2;
      positions.set(u.members[0], { x: leftX, y, depth: u.depth });
      positions.set(u.members[1], {
        x: leftX + NODE_W + COUPLE_GAP,
        y,
        depth: u.depth,
      });
    } else {
      positions.set(u.members[0], {
        x: u.centerX - NODE_W / 2,
        y,
        depth: u.depth,
      });
    }
  };

  const measure = (u: Unit) => {
    const half = unitWidth(u) / 2;
    if (u.children.length === 0) {
      u.shape = { left: [-half], right: [half] };
      u.childOffsets = [];
      return;
    }
    const accLeft: number[] = [];
    const accRight: number[] = [];
    const offsets: number[] = [];
    for (const c of u.children) {
      measure(c);
      const dx = accRight.length === 0 ? 0 : shiftToClear(accRight, c.shape, H_GAP);
      offsets.push(dx);
      mergeContour(accLeft, accRight, c.shape, dx);
    }
    // Center the parent between its first and last child.
    const mid = (offsets[0] + offsets[offsets.length - 1]) / 2;
    u.childOffsets = offsets.map((o) => o - mid);
    const left = [-half];
    const right = [half];
    for (let d = 0; d < accLeft.length; d++) {
      left.push(accLeft[d] - mid);
      right.push(accRight[d] - mid);
    }
    u.shape = { left, right };
  };

  const place = (u: Unit, centerX: number, depth: number) => {
    u.depth = depth;
    u.centerX = centerX;
    placeMembers(u);
    u.children.forEach((c, i) => place(c, centerX + u.childOffsets[i], depth + 1));
  };

  let cursorX = 0;
  const rawGroups: { houseSlug: string | null; minX: number; maxX: number }[] = [];
  groupKeys.forEach((key, gi) => {
    if (gi > 0) cursorX += GROUP_GAP;
    const groupRoots = rootsByHouse.get(key)!;
    // Real trees first, loose single members trailing after them.
    groupRoots.sort((a, b) => {
      const at = a.children.length > 0 ? 0 : 1;
      const bt = b.children.length > 0 ? 0 : 1;
      return at - bt || bornYear(a.members[0]) - bornYear(b.members[0]);
    });
    // Contour-pack the roots of a group against each other as well, so a
    // narrow tree can tuck into the unused rows of a wide one.
    const accLeft: number[] = [];
    const accRight: number[] = [];
    const offsets: number[] = [];
    for (const r of groupRoots) {
      measure(r);
      const dx = accRight.length === 0 ? 0 : shiftToClear(accRight, r.shape, ROOT_GAP);
      offsets.push(dx);
      mergeContour(accLeft, accRight, r.shape, dx);
    }
    const minL = Math.min(...accLeft);
    const maxR = Math.max(...accRight);
    groupRoots.forEach((r, i) => place(r, cursorX - minL + offsets[i], 0));
    rawGroups.push({ houseSlug: key, minX: cursorX, maxX: cursorX + (maxR - minL) });
    cursorX += maxR - minL;
  });

  // Place satellites next to their spouse on the spouse's row, sliding along
  // the row to the nearest free slot.
  const rowIntervals = new Map<number, { x1: number; x2: number }[]>();
  for (const p of positions.values()) {
    const iv = { x1: p.x, x2: p.x + NODE_W };
    const row = rowIntervals.get(p.depth);
    if (row) row.push(iv);
    else rowIntervals.set(p.depth, [iv]);
  }

  const findSlot = (depth: number, desired: number): number => {
    const row = [...(rowIntervals.get(depth) ?? [])].sort((a, b) => a.x1 - b.x1);
    if (row.length === 0) return desired;
    const merged: { x1: number; x2: number }[] = [];
    for (const iv of row) {
      const last = merged[merged.length - 1];
      if (last && iv.x1 <= last.x2 + H_GAP) last.x2 = Math.max(last.x2, iv.x2);
      else merged.push({ ...iv });
    }
    let best = desired;
    let bestDist = Infinity;
    const consider = (lo: number, hi: number) => {
      if (hi - lo < NODE_W) return;
      const x = Math.min(Math.max(desired, lo), hi - NODE_W);
      const dist = Math.abs(x - desired);
      if (dist < bestDist) {
        bestDist = dist;
        best = x;
      }
    };
    consider(merged[0].x1 - 1e7, merged[0].x1 - H_GAP);
    for (let i = 0; i < merged.length - 1; i++) {
      consider(merged[i].x2 + H_GAP, merged[i + 1].x1 - H_GAP);
    }
    consider(merged[merged.length - 1].x2 + H_GAP, merged[merged.length - 1].x2 + 1e7);
    return best;
  };

  const placedSatellites = satellites
    .map((sat) => {
      const spouseId = (marriagesOf.get(sat.members[0]) ?? []).find((s) => positions.has(s));
      return { sat, spouseId };
    })
    .filter((s): s is { sat: Unit; spouseId: number } => s.spouseId != null)
    .sort((a, b) => positions.get(a.spouseId)!.x - positions.get(b.spouseId)!.x);

  for (const { sat, spouseId } of placedSatellites) {
    const sp = positions.get(spouseId)!;
    const spouseUnit = unitOfMember.get(spouseId)!;
    let unitRight = sp.x + NODE_W;
    for (const m of spouseUnit.members) {
      const p = positions.get(m);
      if (p) unitRight = Math.max(unitRight, p.x + NODE_W);
    }
    const x = findSlot(sp.depth, unitRight + H_GAP);
    positions.set(sat.members[0], { x, y: sp.y, depth: sp.depth });
    sat.depth = sp.depth;
    sat.centerX = x + NODE_W / 2;
    const iv = { x1: x, x2: x + NODE_W };
    const row = rowIntervals.get(sp.depth);
    if (row) row.push(iv);
    else rowIntervals.set(sp.depth, [iv]);
  }

  let minX = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  for (const p of positions.values()) {
    minX = Math.min(minX, p.x);
    maxX = Math.max(maxX, p.x + NODE_W);
    maxY = Math.max(maxY, p.y + NODE_H);
  }
  if (!isFinite(minX)) {
    minX = 0;
    maxX = 0;
    maxY = 0;
  }
  const offsetX = PAD - minX;

  const nodes: PositionedNode[] = rawNodes
    .filter((n) => positions.has(n.id))
    .map((n) => {
      const p = positions.get(n.id)!;
      return { ...n, x: p.x + offsetX, y: p.y + PAD, depth: p.depth };
    });

  const nodePos = new Map<number, PositionedNode>();
  for (const n of nodes) nodePos.set(n.id, n);

  const groups: HouseGroup[] = rawGroups.map((g) => ({
    houseSlug: g.houseSlug,
    x: g.minX + offsetX,
    width: g.maxX - g.minX,
  }));

  const parentLinks: ParentLink[] = [];
  for (const c of rawNodes) {
    const child = nodePos.get(c.id);
    if (!child) continue;
    const ps = (parentsOf.get(c.id) ?? []).filter((id) => nodePos.has(id));
    if (ps.length === 0) continue;
    const anchorId = anchorParent(c, ps);
    const anchor = nodePos.get(anchorId)!;
    const anchorUnit = unitOfMember.get(anchorId)!;
    const childUnit = unitOfMember.get(c.id)!;
    const kind: ParentLink["kind"] = parentOfUnit.get(childUnit) === anchorUnit ? "drop" : "cross";

    // Only start from the midpoint of the parents when they are actually
    // placed side by side as a couple; otherwise start from the anchor
    // parent so the link never originates in empty space.
    let fromX: number;
    let fromY: number;
    const other = ps.find((id) => id !== anchorId);
    const otherAdjacent = other != null && unitOfMember.get(other) === anchorUnit;
    if (otherAdjacent) {
      const b = nodePos.get(other)!;
      fromX = (anchor.x + b.x) / 2 + NODE_W / 2;
      fromY = Math.max(anchor.y, b.y) + NODE_H;
    } else {
      fromX = anchor.x + NODE_W / 2;
      fromY = anchor.y + NODE_H;
    }
    parentLinks.push({
      fromX,
      fromY,
      toX: child.x + NODE_W / 2,
      toY: child.y,
      kind,
    });

    // The other biological parent lives in a different unit (a remarriage or
    // a satellite spouse): keep that descent visible with a cross link.
    if (other != null && !otherAdjacent) {
      const b = nodePos.get(other)!;
      parentLinks.push({
        fromX: b.x + NODE_W / 2,
        fromY: b.y + NODE_H,
        toX: child.x + NODE_W / 2,
        toY: child.y,
        kind: "cross",
      });
    }
  }

  const marriageLinks: MarriageLink[] = [];
  const seen = new Set<string>();
  for (const m of marriageEdges) {
    const a = nodePos.get(m.spouseAId);
    const b = nodePos.get(m.spouseBId);
    if (!a || !b) continue;
    const key = coupleKey(m.spouseAId, m.spouseBId);
    if (seen.has(key)) continue;
    seen.add(key);
    const sameUnit = unitOfMember.get(m.spouseAId) === unitOfMember.get(m.spouseBId);
    const left = a.x < b.x ? a : b;
    const right = a.x < b.x ? b : a;
    const inset = (NODE_W - FRAME_W) / 2;
    marriageLinks.push({
      x1: left.x + inset + FRAME_W,
      y1: left.y + FRAME_H / 2,
      x2: right.x + inset,
      y2: right.y + FRAME_H / 2,
      isSecret: m.isSecret,
      kind: sameUnit ? "couple" : "distant",
    });
  }

  return {
    nodes,
    parentLinks,
    marriageLinks,
    groups,
    width: maxX + offsetX + PAD,
    height: maxY + PAD * 2,
  };
}
