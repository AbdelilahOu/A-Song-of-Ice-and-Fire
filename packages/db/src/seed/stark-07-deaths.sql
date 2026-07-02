-- Stark deaths.

WITH d(mslug, yr, loc, cause, killer, battle, descr, confirmed) AS (
  VALUES
   ('rickon-stark-father-of-cregan',121,'winterfell','Died of illness',NULL,NULL,'Died leaving Cregan as a minor heir.',1),
   ('rickon-stark-son-of-cregan',121,NULL,'Died in war',NULL,NULL,'Died young during conflict in the north.',1),
   ('willam-stark',226,NULL,'Slain by wildlings',NULL,NULL,'Killed fighting King-Beyond-the-Wall Raymun Redbeard.',1),
   ('rickard-stark',282,'kings-landing','Burned alive','aerys-ii-targaryen',NULL,'Executed by Aerys II in King''s Landing.',1),
   ('brandon-stark-son-of-rickard',282,'kings-landing','Strangled','aerys-ii-targaryen',NULL,'Strangled trying to save his father.',1),
   ('lyanna-stark',283,'tower-of-joy','Died after childbirth',NULL,NULL,'Died after giving birth at the Tower of Joy.',1),
   ('ned-stark',299,'kings-landing','Executed',NULL,NULL,'Executed on Joffrey Baratheon''s command.',1),
   ('robb-stark',299,'the-twins','Murdered',NULL,'red-wedding','Killed at the Red Wedding.',1),
   ('catelyn-tully',299,'the-twins','Murdered',NULL,'red-wedding','Killed at the Red Wedding.',1)
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
