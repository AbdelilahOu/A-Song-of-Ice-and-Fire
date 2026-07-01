import { getSeedTable, type SeedTable } from "./tables";

export type JsonRecord = Record<string, string | number | boolean | null>;

function quoteIdentifier(identifier: string) {
  return `"${identifier.replaceAll('"', '""')}"`;
}

function getWritableColumns(table: SeedTable, data: JsonRecord) {
  const knownColumns = new Map(table.columns.map((column) => [column.name, column]));
  const columns = Object.keys(data);

  for (const column of columns) {
    const definition = knownColumns.get(column);
    if (!definition) {
      throw new Error(`Unknown column for ${table.name}: ${column}`);
    }
    if (definition.generated) {
      throw new Error(`Generated column cannot be written: ${column}`);
    }
  }

  return columns;
}

export async function listRecords(
  db: D1Database,
  tableName: string,
  limit: number,
  offset: number,
) {
  const table = getSeedTable(tableName);
  const boundedLimit = Math.min(Math.max(limit, 1), 500);
  const boundedOffset = Math.max(offset, 0);
  const result = await db
    .prepare(`select * from ${quoteIdentifier(table.name)} order by id limit ? offset ?`)
    .bind(boundedLimit, boundedOffset)
    .all<JsonRecord>();

  return result.results;
}

export async function getRecord(db: D1Database, tableName: string, id: number) {
  const table = getSeedTable(tableName);
  return db
    .prepare(`select * from ${quoteIdentifier(table.name)} where id = ?`)
    .bind(id)
    .first<JsonRecord>();
}

export async function getRecordBySlug(db: D1Database, tableName: string, slug: string) {
  const table = getSeedTable(tableName);
  const hasSlug = table.columns.some((column) => column.name === "slug");
  if (!hasSlug) {
    throw new Error(`${table.name} does not have a slug column`);
  }

  return db
    .prepare(`select * from ${quoteIdentifier(table.name)} where slug = ?`)
    .bind(slug)
    .first<JsonRecord>();
}

export async function createRecord(db: D1Database, tableName: string, data: JsonRecord) {
  const table = getSeedTable(tableName);
  const columns = getWritableColumns(table, data);
  if (columns.length === 0) {
    throw new Error("create_record requires at least one column");
  }

  const sql = [
    `insert into ${quoteIdentifier(table.name)}`,
    `(${columns.map(quoteIdentifier).join(", ")})`,
    `values (${columns.map(() => "?").join(", ")})`,
  ].join(" ");
  const values = columns.map((column) => data[column]);
  const result = await db
    .prepare(sql)
    .bind(...values)
    .run();
  const id = result.meta.last_row_id;
  if (typeof id !== "number") {
    return { ok: true };
  }

  return getRecord(db, table.name, id);
}

export async function updateRecord(
  db: D1Database,
  tableName: string,
  id: number,
  data: JsonRecord,
) {
  const table = getSeedTable(tableName);
  const columns = getWritableColumns(table, data);
  if (columns.length === 0) {
    throw new Error("update_record requires at least one column");
  }

  const sql = [
    `update ${quoteIdentifier(table.name)}`,
    `set ${columns.map((column) => `${quoteIdentifier(column)} = ?`).join(", ")}`,
    "where id = ?",
  ].join(" ");
  const values = columns.map((column) => data[column]);
  await db
    .prepare(sql)
    .bind(...values, id)
    .run();

  return getRecord(db, table.name, id);
}

export async function deleteRecord(db: D1Database, tableName: string, id: number) {
  const table = getSeedTable(tableName);
  const existing = await getRecord(db, table.name, id);
  if (!existing) {
    return { deleted: false, record: null };
  }

  await db
    .prepare(`delete from ${quoteIdentifier(table.name)} where id = ?`)
    .bind(id)
    .run();
  return { deleted: true, record: existing };
}
