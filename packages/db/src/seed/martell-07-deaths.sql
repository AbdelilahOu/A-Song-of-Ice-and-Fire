-- Martell deaths.

WITH d(mslug, yr, loc, cause, killer, battle, descr, confirmed) AS (
  VALUES
   ('meria-martell',13,'sunspear','Died of old age',NULL,NULL,'Died after preserving Dornish independence.',1),
   ('lewyn-martell',283,'the-trident','Slain in battle',NULL,'battle-of-the-trident','Killed at the Trident while serving Aerys II.',1),
   ('elia-martell',283,'kings-landing','Murdered',NULL,'sack-of-kings-landing','Murdered during the Sack of King''s Landing.',1),
   ('rhaenys-targaryen-younger',283,'kings-landing','Murdered',NULL,'sack-of-kings-landing','Murdered during the Sack of King''s Landing.',1),
   ('aegon-targaryen-son',283,'kings-landing','Murdered',NULL,'sack-of-kings-landing','Murdered as an infant during the Sack.',1),
   ('oberyn-martell',300,'kings-landing','Killed in trial by combat',NULL,NULL,'Killed by Gregor Clegane while fighting for Tyrion.',1),
   ('quentyn-martell',300,NULL,'Burned by dragonfire',NULL,NULL,'Died after attempting to steal a dragon in Meereen.',1)
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
