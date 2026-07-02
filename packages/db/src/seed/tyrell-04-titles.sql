-- Tyrell titles and relations.

WITH t(slug, title, sy, ey, current_flag) AS (
  VALUES
   ('harlen-tyrell','Lord of Highgarden',1,NULL,0),
   ('harlen-tyrell','Lord Paramount of the Mander',1,NULL,0),
   ('theo-tyrell','Lord of Highgarden',129,NULL,0),
   ('leo-tyrell-longthorn','Lord of Highgarden',NULL,NULL,0),
   ('luthor-tyrell','Lord of Highgarden',NULL,281,0),
   ('mace-tyrell','Lord of Highgarden',281,NULL,1),
   ('mace-tyrell','Warden of the South',281,NULL,1),
   ('mace-tyrell','Master of Ships',300,NULL,1),
   ('willas-tyrell','Heir to Highgarden',273,NULL,1),
   ('margaery-tyrell','Queen Consort',300,300,0),
   ('loras-tyrell','Kingsguard Knight',300,NULL,1),
   ('garlan-tyrell','Lord of Brightwater Keep',300,NULL,1)
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
   ('loras-tyrell','renly-baratheon','paramour','Loras and Renly were lovers and political allies.'),
   ('olenna-redwyne','margaery-tyrell','guardian','Olenna guided Margaery through the politics of King''s Landing.')
)
INSERT INTO member_relation (from_member_id, to_member_id, type, notes)
SELECT f.id, tt.id, r.type, r.notes
FROM r JOIN member f ON f.slug=r.from_slug JOIN member tt ON tt.slug=r.to_slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_relation mr
  WHERE mr.from_member_id=f.id AND mr.to_member_id=tt.id AND mr.type=r.type
);
