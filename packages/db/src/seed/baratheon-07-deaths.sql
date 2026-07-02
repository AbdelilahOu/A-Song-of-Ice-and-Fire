-- Baratheon deaths.

WITH d(mslug, yr, loc, cause, killer, battle, descr, confirmed) AS (
  VALUES
   ('argilac-durrandon',-2,'storms-end','Slain in battle','orys-baratheon','last-storm','Killed by Orys Baratheon in the Last Storm.',1),
   ('boremund-baratheon',129,'storms-end','Died of old age',NULL,NULL,'Died before the Dance fully erupted.',1),
   ('borros-baratheon',131,NULL,'Slain in battle',NULL,NULL,'Killed fighting for Aegon II at the Kingsroad.',1),
   ('ormund-baratheon',260,NULL,'Slain in battle',NULL,NULL,'Killed in the War of the Ninepenny Kings.',1),
   ('steffon-baratheon',278,'shipbreaker-bay','Drowned',NULL,NULL,'Drowned returning from a mission to Volantis.',1),
   ('cassana-estermont',278,'shipbreaker-bay','Drowned',NULL,NULL,'Drowned with Steffon Baratheon in Shipbreaker Bay.',1),
   ('robert-baratheon',298,'kings-landing','Mortal wounds from a boar hunt',NULL,NULL,'Died after the boar hunt manipulated by Cersei''s court.',1),
   ('renly-baratheon',299,'storms-end-parley','Murdered by shadow',NULL,NULL,'Killed by a shadow assassin before facing Stannis.',1),
   ('barra',299,'kings-landing','Murdered',NULL,NULL,'Killed during the purge of Robert''s bastards.',1)
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
