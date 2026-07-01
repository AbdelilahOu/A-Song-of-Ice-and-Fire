export function formatYear(year: number | null | undefined): string {
  if (year == null) return "Unknown";
  if (year < 0) return `${-year} BC`;
  return `${year} AC`;
}

export function lifespan(born: number | null | undefined, died: number | null | undefined): string {
  if (born == null && died == null) return "";
  const b = born == null ? "?" : formatYear(born);
  const d = died == null ? "" : formatYear(died);
  return d ? `${b} – ${d}` : `b. ${b}`;
}

export function displayName(m: {
  fullName?: string | null;
  name: string;
  surname?: string | null;
}): string {
  return m.fullName ?? [m.name, m.surname].filter(Boolean).join(" ");
}
