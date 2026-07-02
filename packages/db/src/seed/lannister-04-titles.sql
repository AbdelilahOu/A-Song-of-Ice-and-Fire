-- Lannister titles and non-lineage relations. Idempotent.

WITH t(slug, title, sy, ey, current_flag) AS (
  VALUES
   ('loreon-i-lannister','King of the Rock',NULL,NULL,0),
   ('tybolt-lannister-thunderbolt','King of the Rock',NULL,NULL,0),
   ('tyrion-iii-lannister','King of the Rock',NULL,NULL,0),
   ('gerold-ii-lannister','King of the Rock',NULL,NULL,0),
   ('gerold-iii-lannister','King of the Rock',NULL,NULL,0),
   ('joffrey-lydden','King of the Rock',NULL,NULL,0),
   ('cerion-lannister','King of the Rock',NULL,NULL,0),
   ('tommen-i-lannister','King of the Rock',NULL,NULL,0),
   ('lancel-i-lannister','King of the Rock',NULL,NULL,0),
   ('loreon-iii-lannister','King of the Rock',NULL,NULL,0),
   ('gerold-the-great-lannister','King of the Rock',NULL,NULL,0),
   ('lancel-iv-lannister','King of the Rock',NULL,NULL,0),
   ('tommen-ii-lannister','King of the Rock',NULL,NULL,0),
   ('loren-i-lannister','King of the Rock',NULL,1,0),
   ('loren-i-lannister','Lord of Casterly Rock',1,NULL,0),
   ('loren-i-lannister','Warden of the West',1,NULL,0),
   ('lyman-lannister','Lord of Casterly Rock',42,59,0),
   ('tymond-lannister','Heir to Casterly Rock',80,101,0),
   ('jason-lannister-dance','Lord of Casterly Rock',112,130,0),
   ('tyland-lannister','Master of Ships',120,129,0),
   ('tyland-lannister','Master of Coin',129,131,0),
   ('tyland-lannister','Hand of the King',131,133,0),
   ('loreon-lannister-son-of-jason','Lord of Casterly Rock',130,NULL,0),
   ('johanna-westerling','Regent of Casterly Rock',130,NULL,0),
   ('damon-lannister-grey-lion','Lord of Casterly Rock',184,209,0),
   ('tybolt-lannister-son-of-damon','Lord of Casterly Rock',209,NULL,0),
   ('cerelle-lannister-lady-of-casterly-rock','Lady of Casterly Rock',NULL,NULL,0),
   ('gerold-lannister-golden','Lord of Casterly Rock',NULL,NULL,0),
   ('tytos-lannister','Lord of Casterly Rock',NULL,267,0),
   ('tywin-lannister','Lord of Casterly Rock',267,300,0),
   ('tywin-lannister','Warden of the West',267,300,0),
   ('tywin-lannister','Hand of the King',262,281,0),
   ('tywin-lannister','Hand of the King',299,300,0),
   ('cersei-lannister','Queen Consort',284,298,0),
   ('cersei-lannister','Queen Regent',298,300,0),
   ('cersei-lannister','Lady of Casterly Rock',300,NULL,1),
   ('jaime-lannister','Lord Commander of the Kingsguard',299,NULL,1),
   ('tyrion-lannister','Acting Hand of the King',299,299,0),
   ('tyrion-lannister','Master of Coin',300,300,0),
   ('kevan-lannister','Lord Regent',300,300,0),
   ('kevan-lannister','Protector of the Realm',300,300,0),
   ('lancel-lannister','Lord of Darry',299,300,0),
   ('daven-lannister','Warden of the West',300,NULL,1),
   ('emmon-frey','Lord of Riverrun',300,NULL,1),
   ('ermesande-hayford','Lady of Hayford',299,NULL,1)
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
   ('jaime-lannister','cersei-lannister','twin','Twin children of Tywin and Joanna Lannister.'),
   ('willem-lannister','martyn-lannister','twin','Twin sons of Kevan Lannister and Dorna Swyft.'),
   ('jaime-lannister','cersei-lannister','paramour','Their incest produced Joffrey, Myrcella, and Tommen Baratheon.'),
   ('lancel-lannister','cersei-lannister','paramour','Lancel became Cersei''s lover while serving in King''s Landing.'),
   ('tyrion-lannister','tywin-lannister','other','Tyrion killed Tywin after escaping the black cells.'),
   ('jaime-lannister','aerys-ii-targaryen','other','Jaime slew Aerys II during the Sack of King''s Landing.')
)
INSERT INTO member_relation (from_member_id, to_member_id, type, notes)
SELECT f.id, tt.id, r.type, r.notes
FROM r JOIN member f ON f.slug=r.from_slug JOIN member tt ON tt.slug=r.to_slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_relation mr
  WHERE mr.from_member_id=f.id AND mr.to_member_id=tt.id AND mr.type=r.type
);
