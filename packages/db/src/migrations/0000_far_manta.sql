CREATE TABLE `account` (
	`id` text PRIMARY KEY NOT NULL,
	`account_id` text NOT NULL,
	`provider_id` text NOT NULL,
	`user_id` text NOT NULL,
	`access_token` text,
	`refresh_token` text,
	`id_token` text,
	`access_token_expires_at` integer,
	`refresh_token_expires_at` integer,
	`scope` text,
	`password` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `account_userId_idx` ON `account` (`user_id`);--> statement-breakpoint
CREATE TABLE `session` (
	`id` text PRIMARY KEY NOT NULL,
	`expires_at` integer NOT NULL,
	`token` text NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer NOT NULL,
	`ip_address` text,
	`user_agent` text,
	`user_id` text NOT NULL,
	FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE UNIQUE INDEX `session_token_unique` ON `session` (`token`);--> statement-breakpoint
CREATE INDEX `session_userId_idx` ON `session` (`user_id`);--> statement-breakpoint
CREATE TABLE `user` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`email` text NOT NULL,
	`email_verified` integer DEFAULT false NOT NULL,
	`image` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `user_email_unique` ON `user` (`email`);--> statement-breakpoint
CREATE TABLE `verification` (
	`id` text PRIMARY KEY NOT NULL,
	`identifier` text NOT NULL,
	`value` text NOT NULL,
	`expires_at` integer NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL
);
--> statement-breakpoint
CREATE INDEX `verification_identifier_idx` ON `verification` (`identifier`);--> statement-breakpoint
CREATE TABLE `battle` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`slug` text NOT NULL,
	`name` text NOT NULL,
	`war_id` integer,
	`year` integer,
	`location_id` integer,
	`description` text,
	`outcome` text,
	`victor_side` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`war_id`) REFERENCES `war`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`location_id`) REFERENCES `location`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `battle_slug_unique` ON `battle` (`slug`);--> statement-breakpoint
CREATE INDEX `battle_slug_idx` ON `battle` (`slug`);--> statement-breakpoint
CREATE INDEX `battle_war_idx` ON `battle` (`war_id`);--> statement-breakpoint
CREATE INDEX `battle_location_idx` ON `battle` (`location_id`);--> statement-breakpoint
CREATE TABLE `battle_participant` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`battle_id` integer NOT NULL,
	`house_id` integer,
	`member_id` integer,
	`side` text,
	`role` text,
	`was_commander` integer DEFAULT false NOT NULL,
	`was_killed` integer DEFAULT false NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`battle_id`) REFERENCES `battle`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`house_id`) REFERENCES `house`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `battle_participant_battle_idx` ON `battle_participant` (`battle_id`);--> statement-breakpoint
CREATE INDEX `battle_participant_house_idx` ON `battle_participant` (`house_id`);--> statement-breakpoint
CREATE INDEX `battle_participant_member_idx` ON `battle_participant` (`member_id`);--> statement-breakpoint
CREATE TABLE `war` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`slug` text NOT NULL,
	`name` text NOT NULL,
	`start_year` integer,
	`end_year` integer,
	`description` text,
	`outcome` text,
	`victor_house_id` integer,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`victor_house_id`) REFERENCES `house`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `war_slug_unique` ON `war` (`slug`);--> statement-breakpoint
CREATE INDEX `war_slug_idx` ON `war` (`slug`);--> statement-breakpoint
CREATE TABLE `war_participant` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`war_id` integer NOT NULL,
	`house_id` integer,
	`member_id` integer,
	`side` text,
	`role` text,
	`outcome` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`war_id`) REFERENCES `war`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`house_id`) REFERENCES `house`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `war_participant_war_idx` ON `war_participant` (`war_id`);--> statement-breakpoint
CREATE INDEX `war_participant_house_idx` ON `war_participant` (`house_id`);--> statement-breakpoint
CREATE INDEX `war_participant_member_idx` ON `war_participant` (`member_id`);--> statement-breakpoint
CREATE TABLE `dragon` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`slug` text NOT NULL,
	`name` text NOT NULL,
	`status` text DEFAULT 'unknown' NOT NULL,
	`size` text DEFAULT 'unknown' NOT NULL,
	`color` text,
	`born_year` integer,
	`died_year` integer,
	`notable_rider_id` integer,
	`killed_in_battle_id` integer,
	`description` text,
	`fate` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`notable_rider_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`killed_in_battle_id`) REFERENCES `battle`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `dragon_slug_unique` ON `dragon` (`slug`);--> statement-breakpoint
CREATE INDEX `dragon_slug_idx` ON `dragon` (`slug`);--> statement-breakpoint
CREATE INDEX `dragon_rider_idx` ON `dragon` (`notable_rider_id`);--> statement-breakpoint
CREATE INDEX `dragon_status_idx` ON `dragon` (`status`);--> statement-breakpoint
CREATE TABLE `dragon_rider` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`dragon_id` integer NOT NULL,
	`member_id` integer NOT NULL,
	`start_year` integer,
	`end_year` integer,
	`is_notable` integer DEFAULT false NOT NULL,
	`notes` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`dragon_id`) REFERENCES `dragon`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `dragon_rider_dragon_idx` ON `dragon_rider` (`dragon_id`);--> statement-breakpoint
CREATE INDEX `dragon_rider_member_idx` ON `dragon_rider` (`member_id`);--> statement-breakpoint
CREATE TABLE `death` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`member_id` integer NOT NULL,
	`year` integer,
	`location_id` integer,
	`cause` text,
	`killer_id` integer,
	`battle_id` integer,
	`description` text,
	`is_confirmed` integer DEFAULT true NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`location_id`) REFERENCES `location`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`killer_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`battle_id`) REFERENCES `battle`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `death_member_id_unique` ON `death` (`member_id`);--> statement-breakpoint
CREATE INDEX `death_member_idx` ON `death` (`member_id`);--> statement-breakpoint
CREATE INDEX `death_killer_idx` ON `death` (`killer_id`);--> statement-breakpoint
CREATE INDEX `death_battle_idx` ON `death` (`battle_id`);--> statement-breakpoint
CREATE TABLE `event` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`slug` text NOT NULL,
	`name` text NOT NULL,
	`type` text DEFAULT 'other' NOT NULL,
	`year` integer,
	`end_year` integer,
	`location_id` integer,
	`war_id` integer,
	`battle_id` integer,
	`description` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`location_id`) REFERENCES `location`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`war_id`) REFERENCES `war`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`battle_id`) REFERENCES `battle`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `event_slug_unique` ON `event` (`slug`);--> statement-breakpoint
CREATE INDEX `event_slug_idx` ON `event` (`slug`);--> statement-breakpoint
CREATE INDEX `event_year_idx` ON `event` (`year`);--> statement-breakpoint
CREATE INDEX `event_type_idx` ON `event` (`type`);--> statement-breakpoint
CREATE TABLE `event_participant` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`event_id` integer NOT NULL,
	`member_id` integer,
	`house_id` integer,
	`role` text,
	`notes` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`event_id`) REFERENCES `event`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`house_id`) REFERENCES `house`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `event_participant_event_idx` ON `event_participant` (`event_id`);--> statement-breakpoint
CREATE INDEX `event_participant_member_idx` ON `event_participant` (`member_id`);--> statement-breakpoint
CREATE INDEX `event_participant_house_idx` ON `event_participant` (`house_id`);--> statement-breakpoint
CREATE TABLE `house` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`slug` text NOT NULL,
	`name` text NOT NULL,
	`full_name` text,
	`words` text,
	`region` text,
	`seat` text,
	`sigil_description` text,
	`sigil_colors` text,
	`founded_year` integer,
	`founder_id` integer,
	`current_lord_id` integer,
	`status` text DEFAULT 'extant' NOT NULL,
	`is_great_house` integer DEFAULT false NOT NULL,
	`summary` text,
	`history` text,
	`banner_path` text,
	`frame_path` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX `house_slug_unique` ON `house` (`slug`);--> statement-breakpoint
CREATE INDEX `house_slug_idx` ON `house` (`slug`);--> statement-breakpoint
CREATE INDEX `house_region_idx` ON `house` (`region`);--> statement-breakpoint
CREATE TABLE `house_relation` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`house_a_id` integer NOT NULL,
	`house_b_id` integer NOT NULL,
	`type` text NOT NULL,
	`start_year` integer,
	`end_year` integer,
	`is_current` integer DEFAULT true NOT NULL,
	`description` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`house_a_id`) REFERENCES `house`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`house_b_id`) REFERENCES `house`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `house_relation_a_idx` ON `house_relation` (`house_a_id`);--> statement-breakpoint
CREATE INDEX `house_relation_b_idx` ON `house_relation` (`house_b_id`);--> statement-breakpoint
CREATE INDEX `house_relation_type_idx` ON `house_relation` (`type`);--> statement-breakpoint
CREATE TABLE `location` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`slug` text NOT NULL,
	`name` text NOT NULL,
	`type` text DEFAULT 'other' NOT NULL,
	`region` text,
	`controlling_house_id` integer,
	`description` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`controlling_house_id`) REFERENCES `house`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `location_slug_unique` ON `location` (`slug`);--> statement-breakpoint
CREATE INDEX `location_slug_idx` ON `location` (`slug`);--> statement-breakpoint
CREATE INDEX `location_house_idx` ON `location` (`controlling_house_id`);--> statement-breakpoint
CREATE INDEX `location_region_idx` ON `location` (`region`);--> statement-breakpoint
CREATE TABLE `marriage` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`spouse_a_id` integer NOT NULL,
	`spouse_b_id` integer NOT NULL,
	`status` text DEFAULT 'married' NOT NULL,
	`start_year` integer,
	`end_year` integer,
	`is_secret` integer DEFAULT false NOT NULL,
	`notes` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`spouse_a_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`spouse_b_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `marriage_spouse_a_idx` ON `marriage` (`spouse_a_id`);--> statement-breakpoint
CREATE INDEX `marriage_spouse_b_idx` ON `marriage` (`spouse_b_id`);--> statement-breakpoint
CREATE TABLE `member` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`slug` text NOT NULL,
	`name` text NOT NULL,
	`full_name` text,
	`surname` text,
	`epithet` text,
	`house_id` integer,
	`father_id` integer,
	`mother_id` integer,
	`gender` text DEFAULT 'unknown' NOT NULL,
	`status` text DEFAULT 'unknown' NOT NULL,
	`is_bastard` integer DEFAULT false NOT NULL,
	`is_legitimized` integer DEFAULT false NOT NULL,
	`born_year` integer,
	`died_year` integer,
	`culture` text,
	`portrait_path` text,
	`bio` text,
	`notable_for` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`house_id`) REFERENCES `house`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`father_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE set null,
	FOREIGN KEY (`mother_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE set null
);
--> statement-breakpoint
CREATE UNIQUE INDEX `member_slug_unique` ON `member` (`slug`);--> statement-breakpoint
CREATE INDEX `member_slug_idx` ON `member` (`slug`);--> statement-breakpoint
CREATE INDEX `member_house_idx` ON `member` (`house_id`);--> statement-breakpoint
CREATE INDEX `member_father_idx` ON `member` (`father_id`);--> statement-breakpoint
CREATE INDEX `member_mother_idx` ON `member` (`mother_id`);--> statement-breakpoint
CREATE INDEX `member_status_idx` ON `member` (`status`);--> statement-breakpoint
CREATE TABLE `member_allegiance` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`member_id` integer NOT NULL,
	`house_id` integer NOT NULL,
	`role` text DEFAULT 'member' NOT NULL,
	`is_current` integer DEFAULT true NOT NULL,
	`start_year` integer,
	`end_year` integer,
	`notes` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`house_id`) REFERENCES `house`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `member_allegiance_member_idx` ON `member_allegiance` (`member_id`);--> statement-breakpoint
CREATE INDEX `member_allegiance_house_idx` ON `member_allegiance` (`house_id`);--> statement-breakpoint
CREATE TABLE `member_relation` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`from_member_id` integer NOT NULL,
	`to_member_id` integer NOT NULL,
	`type` text NOT NULL,
	`notes` text,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`from_member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY (`to_member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `member_relation_from_idx` ON `member_relation` (`from_member_id`);--> statement-breakpoint
CREATE INDEX `member_relation_to_idx` ON `member_relation` (`to_member_id`);--> statement-breakpoint
CREATE INDEX `member_relation_type_idx` ON `member_relation` (`type`);--> statement-breakpoint
CREATE TABLE `member_title` (
	`id` integer PRIMARY KEY AUTOINCREMENT NOT NULL,
	`member_id` integer NOT NULL,
	`title` text NOT NULL,
	`start_year` integer,
	`end_year` integer,
	`is_current` integer DEFAULT false NOT NULL,
	`created_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	`updated_at` integer DEFAULT (cast(unixepoch('subsecond') * 1000 as integer)) NOT NULL,
	FOREIGN KEY (`member_id`) REFERENCES `member`(`id`) ON UPDATE no action ON DELETE cascade
);
--> statement-breakpoint
CREATE INDEX `member_title_member_idx` ON `member_title` (`member_id`);