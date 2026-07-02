-- Stark marriages.

WITH pairs(a_slug, b_slug, status, sy, ey, secret, notes) AS (
  VALUES
   ('cregan-stark','arra-norrey','widowed',NULL,121,0,NULL),
   ('cregan-stark','alysanne-blackwood','widowed',132,NULL,0,'Marriage following the Hour of the Wolf.'),
   ('beron-stark','lorna-tyrell','widowed',NULL,NULL,0,NULL),
   ('rickard-stark','lyarra-stark','widowed',NULL,282,0,NULL),
   ('ned-stark','catelyn-tully','widowed',283,299,0,'Marriage pact for Robert''s Rebellion.'),
   ('robb-stark','jeyne-westerling','widowed',299,299,1,'Book-canon secret marriage that broke Robb''s Frey pact.')
)
INSERT INTO marriage (spouse_a_id, spouse_b_id, status, start_year, end_year, is_secret, notes)
SELECT a.id, b.id, p.status, p.sy, p.ey, p.secret, p.notes
FROM pairs p JOIN member a ON a.slug=p.a_slug JOIN member b ON b.slug=p.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM marriage m
  WHERE (m.spouse_a_id=a.id AND m.spouse_b_id=b.id)
     OR (m.spouse_a_id=b.id AND m.spouse_b_id=a.id)
);
