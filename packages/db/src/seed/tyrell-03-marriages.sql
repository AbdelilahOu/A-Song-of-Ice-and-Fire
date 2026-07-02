-- Tyrell marriages.

WITH pairs(a_slug, b_slug, status, sy, ey, secret, notes) AS (
  VALUES
   ('luthor-tyrell','olenna-redwyne','widowed',NULL,281,0,NULL),
   ('mace-tyrell','alerie-hightower','married',NULL,NULL,0,NULL),
   ('garlan-tyrell','leonette-fossoway','married',NULL,NULL,0,NULL),
   ('renly-baratheon','margaery-tyrell','widowed',299,299,0,'Tyrell marriage pact supporting Renly''s claim.'),
   ('joffrey-baratheon','margaery-tyrell','widowed',300,300,0,'Joffrey died at the wedding feast.'),
   ('tommen-baratheon','margaery-tyrell','married',300,NULL,0,'Marriage binding the Tyrells to the Iron Throne.')
)
INSERT INTO marriage (spouse_a_id, spouse_b_id, status, start_year, end_year, is_secret, notes)
SELECT a.id, b.id, p.status, p.sy, p.ey, p.secret, p.notes
FROM pairs p JOIN member a ON a.slug=p.a_slug JOIN member b ON b.slug=p.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM marriage m
  WHERE (m.spouse_a_id=a.id AND m.spouse_b_id=b.id)
     OR (m.spouse_a_id=b.id AND m.spouse_b_id=a.id)
);
