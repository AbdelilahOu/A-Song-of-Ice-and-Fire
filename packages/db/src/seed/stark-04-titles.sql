-- Stark titles and relations.

WITH t(slug, title, sy, ey, current_flag) AS (
  VALUES
   ('brandon-the-builder','King in the North',NULL,NULL,0),
   ('theon-stark','King in the North',NULL,NULL,0),
   ('torrhen-stark','King in the North',NULL,1,0),
   ('torrhen-stark','Lord of Winterfell',1,NULL,0),
   ('cregan-stark','Lord of Winterfell',121,NULL,0),
   ('cregan-stark','Hand of the King',131,131,0),
   ('beron-stark','Lord of Winterfell',NULL,NULL,0),
   ('willam-stark','Lord of Winterfell',NULL,226,0),
   ('edwyle-stark','Lord of Winterfell',NULL,NULL,0),
   ('rickard-stark','Lord of Winterfell',NULL,282,0),
   ('ned-stark','Lord of Winterfell',283,299,0),
   ('ned-stark','Hand of the King',298,299,0),
   ('robb-stark','King in the North and Trident',299,299,0),
   ('benjen-stark','First Ranger of the Night''s Watch',NULL,NULL,0)
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
   ('ned-stark','robert-baratheon','fostered_by','Eddard and Robert were fostered together by Jon Arryn.'),
   ('ned-stark','jon-arryn','ward','Jon Arryn fostered Eddard Stark at the Eyrie.'),
   ('lyanna-stark','rhaegar-targaryen','paramour','Their hidden union triggered the political crisis behind Robert''s Rebellion.'),
   ('jon-snow','benjen-stark','other','Benjen was Jon''s uncle and model for joining the Night''s Watch.')
)
INSERT INTO member_relation (from_member_id, to_member_id, type, notes)
SELECT f.id, tt.id, r.type, r.notes
FROM r JOIN member f ON f.slug=r.from_slug JOIN member tt ON tt.slug=r.to_slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_relation mr
  WHERE mr.from_member_id=f.id AND mr.to_member_id=tt.id AND mr.type=r.type
);
