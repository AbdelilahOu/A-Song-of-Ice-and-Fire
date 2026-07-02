-- Baratheon titles and relations.

WITH t(slug, title, sy, ey, current_flag) AS (
  VALUES
   ('orys-baratheon','Lord of Storm''s End',1,NULL,0),
   ('orys-baratheon','Hand of the King',1,5,0),
   ('rogar-baratheon','Lord of Storm''s End',NULL,NULL,0),
   ('rogar-baratheon','Hand of the King',48,50,0),
   ('boremund-baratheon','Lord of Storm''s End',NULL,129,0),
   ('borros-baratheon','Lord of Storm''s End',129,131,0),
   ('lyonel-baratheon','Lord of Storm''s End',NULL,NULL,0),
   ('ormund-baratheon','Lord of Storm''s End',NULL,260,0),
   ('ormund-baratheon','Hand of the King',259,260,0),
   ('steffon-baratheon','Lord of Storm''s End',260,278,0),
   ('robert-baratheon','Lord of Storm''s End',278,283,0),
   ('robert-baratheon','King of the Andals, the Rhoynar, and the First Men',283,298,0),
   ('stannis-baratheon','Lord of Dragonstone',283,NULL,1),
   ('stannis-baratheon','King Claimant',299,NULL,1),
   ('renly-baratheon','Lord of Storm''s End',283,299,0),
   ('renly-baratheon','King Claimant',299,299,0),
   ('shireen-baratheon','Princess of Dragonstone',289,NULL,1)
)
INSERT INTO member_title (member_id, title, start_year, end_year, is_current)
SELECT m.id, t.title, t.sy, t.ey, t.current_flag
FROM t JOIN member m ON m.slug=t.slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_title mt
  WHERE mt.member_id=m.id AND mt.title=t.title AND COALESCE(mt.start_year,-99999)=COALESCE(t.sy,-99999)
);

WITH r(from_slug, to_slug, type, notes) AS (
  VALUES
   ('robert-baratheon','ned-stark','fostered_by','Robert and Eddard Stark were fostered together at the Eyrie by Jon Arryn.'),
   ('robert-baratheon','jon-arryn','fostered_by','Robert was fostered by Jon Arryn before the rebellion.'),
   ('renly-baratheon','loras-tyrell','paramour','Their relationship underpinned Renly''s alliance with House Tyrell.'),
   ('stannis-baratheon','melisandre','other','Melisandre served as Stannis''s red priestess and chief supernatural adviser.')
)
INSERT INTO member_relation (from_member_id, to_member_id, type, notes)
SELECT f.id, tt.id, r.type, r.notes
FROM r JOIN member f ON f.slug=r.from_slug JOIN member tt ON tt.slug=r.to_slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_relation mr
  WHERE mr.from_member_id=f.id AND mr.to_member_id=tt.id AND mr.type=r.type
);
