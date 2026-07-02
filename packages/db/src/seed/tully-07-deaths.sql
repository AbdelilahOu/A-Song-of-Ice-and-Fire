-- Tully deaths.

WITH d(mslug, yr, loc, cause, killer, battle, descr, confirmed) AS (
  VALUES
   ('grover-tully',130,'riverrun','Died of old age',NULL,NULL,'Died after lingering through the early Dance.',1),
   ('elmo-tully',130,'riverrun','Sudden illness',NULL,NULL,'Died shortly after declaring for Rhaenyra.',1),
   ('hoster-tully',299,'riverrun','Died of illness',NULL,NULL,'Died during the War of the Five Kings.',1),
   ('catelyn-tully',299,'the-twins','Murdered',NULL,'red-wedding','Killed at the Red Wedding.',1),
   ('robb-stark',299,'the-twins','Murdered',NULL,'red-wedding','Murdered at the Red Wedding.',1),
   ('lysa-tully',300,NULL,'Pushed through the Moon Door','petyr-baelish',NULL,'Murdered by Petyr Baelish in the Eyrie.',1),
   ('jon-arryn',298,'kings-landing','Poisoned','lysa-tully',NULL,'Poisoned by Lysa at Petyr Baelish''s urging.',1),
   ('ned-stark',299,'kings-landing','Executed',NULL,NULL,'Executed by Joffrey Baratheon.',1)
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
