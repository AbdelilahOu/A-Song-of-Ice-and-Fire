-- Tully titles and relations.

WITH t(slug, title, sy, ey, current_flag) AS (
  VALUES
   ('edmure-tully-ancestor','Lord Paramount of the Trident',1,NULL,0),
   ('edmure-tully-ancestor','Lord of Riverrun',1,NULL,0),
   ('grover-tully','Lord of Riverrun',NULL,130,0),
   ('elmo-tully','Lord of Riverrun',130,130,0),
   ('kermit-tully','Lord of Riverrun',130,NULL,0),
   ('hoster-tully','Lord of Riverrun',NULL,299,0),
   ('hoster-tully','Lord Paramount of the Trident',NULL,299,0),
   ('brynden-tully','Knight of the Gate',299,300,0),
   ('edmure-tully','Lord of Riverrun',299,NULL,1),
   ('robb-stark','King in the North and Trident',299,299,0)
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
   ('brynden-tully','hoster-tully','sibling','Brynden and Hoster were brothers whose relationship was strained by Brynden''s refusal to marry.'),
   ('catelyn-tully','petyr-baelish','ward','Petyr Baelish was fostered at Riverrun and loved Catelyn.'),
   ('lysa-tully','petyr-baelish','paramour','Their secret relationship shaped the murders that opened the main saga.')
)
INSERT INTO member_relation (from_member_id, to_member_id, type, notes)
SELECT f.id, tt.id, r.type, r.notes
FROM r JOIN member f ON f.slug=r.from_slug JOIN member tt ON tt.slug=r.to_slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_relation mr
  WHERE mr.from_member_id=f.id AND mr.to_member_id=tt.id AND mr.type=r.type
);
