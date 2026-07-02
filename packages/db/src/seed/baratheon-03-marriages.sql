-- Baratheon marriages.

WITH pairs(a_slug, b_slug, status, sy, ey, secret, notes) AS (
  VALUES
   ('orys-baratheon','argella-durrandon','widowed',1,NULL,0,NULL),
   ('rogar-baratheon','alyssa-velaryon','widowed',50,54,0,NULL),
   ('ormund-baratheon','rhaelle-targaryen','widowed',NULL,260,0,'Marriage tying House Baratheon to Aegon V''s line.'),
   ('steffon-baratheon','cassana-estermont','widowed',NULL,278,0,NULL),
   ('robert-baratheon','cersei-lannister','widowed',284,298,0,NULL),
   ('stannis-baratheon','selyse-florent','married',286,NULL,0,NULL),
   ('renly-baratheon','margaery-tyrell','widowed',299,299,0,'Political marriage backing Renly''s royal claim.')
)
INSERT INTO marriage (spouse_a_id, spouse_b_id, status, start_year, end_year, is_secret, notes)
SELECT a.id, b.id, p.status, p.sy, p.ey, p.secret, p.notes
FROM pairs p JOIN member a ON a.slug=p.a_slug JOIN member b ON b.slug=p.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM marriage m
  WHERE (m.spouse_a_id=a.id AND m.spouse_b_id=b.id)
     OR (m.spouse_a_id=b.id AND m.spouse_b_id=a.id)
);
