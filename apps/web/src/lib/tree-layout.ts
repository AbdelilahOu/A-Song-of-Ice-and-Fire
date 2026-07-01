// Dependency-free family-tree layout. Turns the API's node/edge graph into
// positioned nodes plus drawable parent-child and marriage links.
//
// Members are grouped into "units": a married pair is one unit, a single person
// is a unit of one. Children hang beneath the unit of one of their parents, and
// each unit is centred over its children (a simple tidy-tree pass).

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

export type ParentLink = {
  fromX: number;
  fromY: number;
  toX: number;
  toY: number;
};

export type MarriageLink = {
  x1: number;
  y1: number;
  x2: number;
  y2: number;
  isSecret: boolean;
};

export type LayoutResult = {
  nodes: PositionedNode[];
  parentLinks: ParentLink[];
  marriageLinks: MarriageLink[];
  width: number;
  height: number;
};

// A node is a 3:4 frame (matching the frame art) plus a name label below it.
export const FRAME_W = 116;
export const FRAME_H = 155; // 116 * 2176/1632 ≈ 155
export const NODE_W = 128;
export const NODE_H = 208; // frame + label
const H_GAP = 30;
const V_GAP = 72;
const COUPLE_GAP = 26;
const PAD = 60;

type Unit = {
  members: number[]; // member ids, 1 or 2
  children: Unit[];
  depth: number;
  centerX: number;
  subtreeW: number; // reserved horizontal band for this whole subtree
  childrenW: number; // total width of the children row
};

export function layoutTree(
  rawNodes: TreeNodeInput[],
  parentEdges: ParentEdgeInput[],
  marriageEdges: MarriageEdgeInput[],
): LayoutResult {
  const nodeById = new Map<number, TreeNodeInput>();
  for (const n of rawNodes) nodeById.set(n.id, n);

  const spouseOf = new Map<number, number>();
  for (const m of marriageEdges) {
    if (nodeById.has(m.spouseAId) && nodeById.has(m.spouseBId)) {
      if (!spouseOf.has(m.spouseAId)) spouseOf.set(m.spouseAId, m.spouseBId);
      if (!spouseOf.has(m.spouseBId)) spouseOf.set(m.spouseBId, m.spouseAId);
    }
  }

  const parentsOf = new Map<number, number[]>();
  for (const e of parentEdges) {
    if (!nodeById.has(e.parentId) || !nodeById.has(e.childId)) continue;
    const arr = parentsOf.get(e.childId) ?? [];
    arr.push(e.parentId);
    parentsOf.set(e.childId, arr);
  }

  // Build units (couples + singles).
  const unitOfMember = new Map<number, Unit>();
  const units: Unit[] = [];
  const bornYear = (id: number) => nodeById.get(id)?.bornYear ?? 9999;

  for (const n of rawNodes) {
    if (unitOfMember.has(n.id)) continue;
    const spouse = spouseOf.get(n.id);
    const members = spouse != null && nodeById.has(spouse) ? [n.id, spouse] : [n.id];
    members.sort((a, b) => (a === n.id ? -1 : b === n.id ? 1 : 0));
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

  // Attach each child unit to exactly one parent unit.
  const parentOfUnit = new Map<Unit, Unit>();
  const childNodes = [...rawNodes].sort((a, b) => bornYear(a.id) - bornYear(b.id));
  for (const c of childNodes) {
    const ps = parentsOf.get(c.id);
    if (!ps || ps.length === 0) continue;
    // Prefer the father, else the first available parent.
    const father = c.fatherId != null && ps.includes(c.fatherId) ? c.fatherId : null;
    const parentId = father ?? ps[0];
    const parentUnit = unitOfMember.get(parentId);
    const childUnit = unitOfMember.get(c.id);
    if (!parentUnit || !childUnit || parentUnit === childUnit) continue;
    if (parentOfUnit.has(childUnit)) continue; // already placed
    parentOfUnit.set(childUnit, parentUnit);
    parentUnit.children.push(childUnit);
  }

  // Sort children within each unit by birth year.
  for (const u of units) {
    u.children.sort((a, b) => bornYear(a.members[0]) - bornYear(b.members[0]));
  }

  const roots = units
    .filter((u) => !parentOfUnit.has(u))
    .sort((a, b) => bornYear(a.members[0]) - bornYear(b.members[0]));

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

  // Pass 1 (bottom-up): reserve a horizontal band = max(own width, children row).
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

  // Pass 2 (top-down): centre each unit in its band; centre the children row
  // under it. Because each subtree owns a disjoint band, nothing can overlap.
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
  for (const r of roots) {
    measure(r);
    place(r, cursorX, 0);
    cursorX += r.subtreeW + H_GAP * 2;
  }

  // Normalise coordinates and add padding.
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

  // Parent-child links: from the midpoint below the parent(s) to the child top.
  const parentLinks: ParentLink[] = [];
  for (const c of rawNodes) {
    const child = nodePos.get(c.id);
    if (!child) continue;
    const ps = (parentsOf.get(c.id) ?? []).filter((id) => nodePos.has(id));
    if (ps.length === 0) continue;
    let fromX: number;
    let fromY: number;
    if (ps.length >= 2) {
      const a = nodePos.get(ps[0])!;
      const b = nodePos.get(ps[1])!;
      fromX = (a.x + b.x) / 2 + NODE_W / 2;
      fromY = Math.max(a.y, b.y) + NODE_H;
    } else {
      const a = nodePos.get(ps[0])!;
      fromX = a.x + NODE_W / 2;
      fromY = a.y + NODE_H;
    }
    parentLinks.push({
      fromX,
      fromY,
      toX: child.x + NODE_W / 2,
      toY: child.y,
    });
  }

  // Marriage links: horizontal connector between spouses.
  const marriageLinks: MarriageLink[] = [];
  const seen = new Set<string>();
  for (const m of marriageEdges) {
    const a = nodePos.get(m.spouseAId);
    const b = nodePos.get(m.spouseBId);
    if (!a || !b) continue;
    const key = [m.spouseAId, m.spouseBId].sort().join("-");
    if (seen.has(key)) continue;
    seen.add(key);
    const left = a.x < b.x ? a : b;
    const right = a.x < b.x ? b : a;
    const inset = (NODE_W - FRAME_W) / 2;
    marriageLinks.push({
      x1: left.x + inset + FRAME_W,
      y1: left.y + FRAME_H / 2,
      x2: right.x + inset,
      y2: right.y + FRAME_H / 2,
      isSecret: m.isSecret,
    });
  }

  return {
    nodes,
    parentLinks,
    marriageLinks,
    width: maxX + offsetX + PAD,
    height: maxY + PAD * 2,
  };
}
