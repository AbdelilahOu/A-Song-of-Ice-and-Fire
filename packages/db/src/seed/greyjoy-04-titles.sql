-- Greyjoy titles and relations.

WITH t(slug, title, sy, ey, current_flag) AS (
  VALUES
   ('vickon-greyjoy','Lord Reaper of Pyke',1,NULL,0),
   ('dalton-greyjoy','Lord Reaper of Pyke',NULL,133,0),
   ('dagon-greyjoy','Lord Reaper of Pyke',NULL,NULL,0),
   ('quellon-greyjoy','Lord Reaper of Pyke',NULL,283,0),
   ('balon-greyjoy','Lord Reaper of Pyke',283,299,0),
   ('balon-greyjoy','King of the Isles and the North',299,299,0),
   ('euron-greyjoy','King of the Isles and the North',300,NULL,1),
   ('victarion-greyjoy','Lord Captain of the Iron Fleet',289,NULL,1),
   ('aeron-greyjoy','Priest of the Drowned God',289,NULL,1),
   ('asha-greyjoy','Captain of the Black Wind',299,NULL,1),
   ('theon-greyjoy','Prince of the Iron Islands',278,NULL,1)
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
   ('theon-greyjoy','ned-stark','ward','Theon was taken as Eddard Stark''s ward and hostage after the Greyjoy Rebellion.'),
   ('euron-greyjoy','aeron-greyjoy','sibling','Euron tormented Aeron and later seized the Seastone Chair.'),
   ('asha-greyjoy','theon-greyjoy','sibling','Children of Balon and Alannys Greyjoy.')
)
INSERT INTO member_relation (from_member_id, to_member_id, type, notes)
SELECT f.id, tt.id, r.type, r.notes
FROM r JOIN member f ON f.slug=r.from_slug JOIN member tt ON tt.slug=r.to_slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_relation mr
  WHERE mr.from_member_id=f.id AND mr.to_member_id=tt.id AND mr.type=r.type
);
