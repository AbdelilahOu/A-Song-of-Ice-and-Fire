-- Greyjoy deaths.

WITH d(mslug, yr, loc, cause, killer, battle, descr, confirmed) AS (
  VALUES
   ('dalton-greyjoy',133,'pyke','Murdered by salt wife',NULL,NULL,'Killed in his sleep by Tess, one of his salt wives.',1),
   ('quellon-greyjoy',283,NULL,'Died of wounds',NULL,NULL,'Died after fighting late in Robert''s Rebellion.',1),
   ('rodrik-greyjoy',289,NULL,'Slain in battle',NULL,NULL,'Killed during the Greyjoy Rebellion.',1),
   ('maron-greyjoy',289,'pyke','Crushed by falling tower',NULL,'siege-of-pyke','Killed when a tower collapsed during the assault on Pyke.',1),
   ('balon-greyjoy',299,'pyke','Fell from a bridge',NULL,NULL,'Died falling from a rope bridge during a storm.',1),
   ('urrigon-greyjoy',NULL,'pyke','Infected wound',NULL,NULL,'Died after a maester treated a finger dance wound.',1)
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
