-- Regnal + notable titles, and a few non-lineage relations. Idempotent.

WITH t(slug, title, sy, ey) AS (
  VALUES
   ('aegon-i-targaryen','King of the Andals, the Rhoynar, and the First Men',1,37),
   ('aenys-i-targaryen','King of the Andals, the Rhoynar, and the First Men',37,42),
   ('maegor-i-targaryen','King of the Andals, the Rhoynar, and the First Men',42,48),
   ('jaehaerys-i-targaryen','King of the Andals, the Rhoynar, and the First Men',48,103),
   ('viserys-i-targaryen','King of the Andals, the Rhoynar, and the First Men',103,129),
   ('rhaenyra-targaryen','Queen of the Andals, the Rhoynar, and the First Men',129,130),
   ('aegon-ii-targaryen','King of the Andals, the Rhoynar, and the First Men',129,131),
   ('aegon-iii-targaryen','King of the Andals, the Rhoynar, and the First Men',131,157),
   ('daeron-i-targaryen','King of the Andals, the Rhoynar, and the First Men',157,161),
   ('baelor-i-targaryen','King of the Andals, the Rhoynar, and the First Men',161,171),
   ('viserys-ii-targaryen','King of the Andals, the Rhoynar, and the First Men',171,172),
   ('aegon-iv-targaryen','King of the Andals, the Rhoynar, and the First Men',172,184),
   ('daeron-ii-targaryen','King of the Andals, the Rhoynar, and the First Men',184,209),
   ('aerys-i-targaryen','King of the Andals, the Rhoynar, and the First Men',209,221),
   ('maekar-i-targaryen','King of the Andals, the Rhoynar, and the First Men',221,233),
   ('aegon-v-targaryen','King of the Andals, the Rhoynar, and the First Men',233,259),
   ('jaehaerys-ii-targaryen','King of the Andals, the Rhoynar, and the First Men',259,262),
   ('aerys-ii-targaryen','King of the Andals, the Rhoynar, and the First Men',262,283),
   ('aemon-targaryen-prince','Prince of Dragonstone',62,92),
   ('baelon-targaryen','Prince of Dragonstone',92,101),
   ('rhaegar-targaryen','Prince of Dragonstone',276,283),
   ('baelor-breakspear','Prince of Dragonstone',184,209),
   ('corlys-velaryon','Lord of the Tides',NULL,132),
   ('corlys-velaryon','Hand of the King',130,132),
   ('brynden-rivers','Hand of the King',209,221),
   ('aemon-dragonknight','Lord Commander of the Kingsguard',NULL,178),
   ('daemon-blackfyre','Lord of Blackfyre',184,196),
   ('aemon-maester','Maester of the Night''s Watch',233,300)
)
INSERT INTO member_title (member_id, title, start_year, end_year, is_current)
SELECT m.id, t.title, t.sy, t.ey, 0
FROM t JOIN member m ON m.slug=t.slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_title mt WHERE mt.member_id=m.id AND mt.title=t.title
);

-- Non-lineage relations (twins, paramour). Idempotent on (from,to,type).
WITH r(from_slug, to_slug, type, notes) AS (
  VALUES
   ('baela-targaryen','rhaena-targaryen-morning','twin','Twin daughters of Daemon Targaryen and Laena Velaryon.'),
   ('rhaegar-targaryen','lyanna-stark','paramour','Their union at the Tower of Joy set Robert''s Rebellion aflame.')
)
INSERT INTO member_relation (from_member_id, to_member_id, type, notes)
SELECT f.id, tt.id, r.type, r.notes
FROM r JOIN member f ON f.slug=r.from_slug JOIN member tt ON tt.slug=r.to_slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_relation mr
  WHERE mr.from_member_id=f.id AND mr.to_member_id=tt.id AND mr.type=r.type
);
