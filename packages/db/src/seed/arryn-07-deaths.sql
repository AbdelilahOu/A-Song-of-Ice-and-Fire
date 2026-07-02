-- Arryn deaths.

WITH d(mslug, yr, loc, cause, killer, battle, descr, confirmed) AS (
  VALUES
   ('robar-ii-royce',NULL,NULL,'Slain or defeated in conquest','artys-arryn','battle-of-the-seven-stars','Defeated by Artys Arryn in the legendary Andal conquest.',0),
   ('jeyne-arryn',134,'the-eyrie','Died of illness',NULL,NULL,'Died after naming Joffrey Arryn her heir.',1),
   ('jon-arryn',298,'kings-landing','Poisoned','lysa-tully',NULL,'Poisoned by Lysa at Littlefinger''s urging.',1),
   ('lysa-tully',300,'moon-door','Pushed through the Moon Door','petyr-baelish',NULL,'Murdered by Littlefinger in the Eyrie.',1)
)
INSERT INTO death (member_id, year, location_id, cause, killer_id, battle_id, description, is_confirmed)
SELECT m.id, d.yr, (SELECT id FROM location WHERE slug=d.loc), d.cause,
       (SELECT id FROM member WHERE slug=d.killer), (SELECT id FROM battle WHERE slug=d.battle),
       d.descr, d.confirmed
FROM d JOIN member m ON m.slug=d.mslug
WHERE true
ON CONFLICT(member_id) DO UPDATE SET
  year=COALESCE(excluded.year, death.year),
  location_id=COALESCE(excluded.location_id, death.location_id),
  cause=excluded.cause,
  killer_id=COALESCE(excluded.killer_id, death.killer_id),
  battle_id=COALESCE(excluded.battle_id, death.battle_id),
  description=excluded.description,
  is_confirmed=excluded.is_confirmed,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));
