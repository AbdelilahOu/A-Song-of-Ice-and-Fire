-- Tully marriages.

WITH pairs(a_slug, b_slug, status, sy, ey, secret, notes) AS (
  VALUES
   ('hoster-tully','minisa-whent','widowed',NULL,NULL,0,NULL),
   ('catelyn-tully','ned-stark','widowed',283,299,0,'Marriage pact joining Tully and Stark for Robert''s Rebellion.'),
   ('lysa-tully','jon-arryn','widowed',283,298,0,'Marriage pact joining Tully and Arryn for Robert''s Rebellion.'),
   ('edmure-tully','roslin-frey','married',299,NULL,0,'Wedding used as the cover for the Red Wedding.')
)
INSERT INTO marriage (spouse_a_id, spouse_b_id, status, start_year, end_year, is_secret, notes)
SELECT a.id, b.id, p.status, p.sy, p.ey, p.secret, p.notes
FROM pairs p JOIN member a ON a.slug=p.a_slug JOIN member b ON b.slug=p.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM marriage m
  WHERE (m.spouse_a_id=a.id AND m.spouse_b_id=b.id)
     OR (m.spouse_a_id=b.id AND m.spouse_b_id=a.id)
);
