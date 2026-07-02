-- Tyrell deaths.

WITH d(mslug, yr, loc, cause, killer, battle, descr, confirmed) AS (
  VALUES
   ('luthor-tyrell',281,'highgarden','Fell from a cliff while hawking',NULL,NULL,'Died in a riding accident while hawking.',1),
   ('joffrey-baratheon',300,'purple-wedding','Poisoned',NULL,NULL,'Poisoned at his wedding feast to Margaery Tyrell.',1),
   ('margaery-tyrell',300,'sept-of-baelor','Killed in wildfire explosion',NULL,NULL,'Show-continuity death at the destruction of the Great Sept; book status may differ.',0)
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
