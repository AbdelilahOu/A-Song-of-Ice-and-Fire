-- Lannister marriages. Idempotent: inserts a pair only if no marriage already
-- links those two members in either order.

WITH pairs(a_slug, b_slug, status, sy, ey, secret, notes) AS (
  VALUES
   ('joffrey-lydden','lannister-daughter-of-gerold-iii','married',NULL,NULL,0,'Joffrey Lydden took the Lannister name through this marriage.'),
   ('lyman-lannister','jocasta-tarbeck','widowed',NULL,59,0,NULL),
   ('jason-lannister-dance','johanna-westerling','widowed',NULL,130,0,NULL),
   ('damon-lannister-grey-lion','cerissa-brax','widowed',NULL,209,0,NULL),
   ('tybolt-lannister-son-of-damon','teora-kyndall','widowed',NULL,NULL,0,NULL),
   ('gerold-lannister-golden','alysanne-farman','widowed',NULL,NULL,0,NULL),
   ('gerold-lannister-golden','rohanne-webber','separated',NULL,NULL,0,'Rohanne vanished under mysterious circumstances after bearing Gerold''s children.'),
   ('tytos-lannister','jeyne-marbrand','widowed',NULL,267,0,NULL),
   ('jason-lannister-son-of-gerold','marla-prester','widowed',NULL,NULL,0,NULL),
   ('tywin-lannister','joanna-lannister','widowed',263,273,0,NULL),
   ('kevan-lannister','dorna-swyft','married',NULL,300,0,NULL),
   ('genna-lannister','emmon-frey','married',252,NULL,0,NULL),
   ('tygett-lannister','darlessa-marbrand','widowed',NULL,285,0,NULL),
   ('cersei-lannister','robert-baratheon','widowed',284,298,0,NULL),
   ('tyrion-lannister','tysha','separated',286,286,1,'Tyrion''s first marriage was forcibly ended by Tywin.'),
   ('tyrion-lannister','sansa-stark','separated',299,NULL,0,'Forced political marriage after the fall of House Stark.'),
   ('tyrek-lannister','ermesande-hayford','married',299,NULL,0,'Political marriage to the infant Lady of Hayford.')
)
INSERT INTO marriage (spouse_a_id, spouse_b_id, status, start_year, end_year, is_secret, notes)
SELECT a.id, b.id, p.status, p.sy, p.ey, p.secret, p.notes
FROM pairs p JOIN member a ON a.slug=p.a_slug JOIN member b ON b.slug=p.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM marriage m
  WHERE (m.spouse_a_id=a.id AND m.spouse_b_id=b.id)
     OR (m.spouse_a_id=b.id AND m.spouse_b_id=a.id)
);
