CREATE TABLE `achievement` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`member_id` integer,
	`dragon_id` integer,
	`title` text NOT NULL,
	`year` integer,
	`category` text,
	`description` text,
	`sort_order` integer DEFAULT 0 NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`dragon_id`) REFERENCES `dragon`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `achievement_member_idx` ON `achievement` (`member_id`);--> statement-breakpoint
CREATE INDEX `achievement_dragon_idx` ON `achievement` (`dragon_id`);--> statement-breakpoint
CREATE INDEX `achievement_year_idx` ON `achievement` (`year`);--> statement-breakpoint
ALTER TABLE `dragon` ADD `epithet` text;--> statement-breakpoint
ALTER TABLE `dragon` ADD `notable_for` text;