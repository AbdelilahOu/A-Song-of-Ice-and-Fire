export type UpsertOutcome<T> = { status: "created" | "updated"; record: T };

export type LinkOutcome<T> = { status: "created" | "exists"; record: T };
