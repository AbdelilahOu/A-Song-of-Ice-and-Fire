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
// parent placed elsewhere on the canvas (a spouse who married into another
// tree, a parent from another house) and should be drawn as curves.
export type ParentLink = {
  fromX: number;
  fromY: number;
  toX: number;
  toY: number;
  kind: "drop" | "cross";
};

// "couple" links join two spouses placed side by side; "distant" links join
// spouses laid out in different units, possibly far apart.
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

type Unit = {
  members: number[];
  children: Unit[];
  depth: number;
  centerX: number;
  subtreeW: number;
  childrenW: number;
};

const coupleKey = (a: number, b: number) => (a < b ? `${a}-${b}` : `${b}-${a}`);

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
      subtreeW: 0,
      childrenW: 0,
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

  // Roots are laid out grouped by house so each house's lineage forms its own
  // cluster instead of interleaving with the others.
  const roots = units.filter((u) => !parentOfUnit.has(u));
  const houseKeyOf = (u: Unit) => nodeById.get(u.members[0])?.house?.slug ?? null;

  const rootsByHouse = new Map<string | null, Unit[]>();
  for (const r of roots) {
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
    const own = unitWidth(u);
    if (u.children.length === 0) {
      u.childrenW = 0;
      u.subtreeW = own;
      return;
    }
    let cw = 0;
    u.children.forEach((c, i) => {
      measure(c);
      cw += c.subtreeW + (i > 0 ? H_GAP : 0);
    });
    u.childrenW = cw;
    u.subtreeW = Math.max(own, cw);
  };

  const place = (u: Unit, x0: number, depth: number) => {
    u.depth = depth;
    u.centerX = x0 + u.subtreeW / 2;
    if (u.children.length > 0) {
      let cx = x0 + (u.subtreeW - u.childrenW) / 2;
      for (const c of u.children) {
        place(c, cx, depth + 1);
        cx += c.subtreeW + H_GAP;
      }
    }
    placeMembers(u);
  };

  let cursorX = 0;
  const rawGroups: { houseSlug: string | null; minX: number; maxX: number }[] = [];
  groupKeys.forEach((key, gi) => {
    if (gi > 0) cursorX += GROUP_GAP;
    const groupStart = cursorX;
    const groupRoots = rootsByHouse.get(key)!;
    // Real trees first, loose single members trailing after them.
    groupRoots.sort((a, b) => {
      const at = a.children.length > 0 ? 0 : 1;
      const bt = b.children.length > 0 ? 0 : 1;
      return at - bt || bornYear(a.members[0]) - bornYear(b.members[0]);
    });
    groupRoots.forEach((r, i) => {
      if (i > 0) cursorX += ROOT_GAP;
      measure(r);
      place(r, cursorX, 0);
      cursorX += r.subtreeW;
    });
    rawGroups.push({ houseSlug: key, minX: groupStart, maxX: cursorX });
  });

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
    if (other != null && unitOfMember.get(other) === anchorUnit) {
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
