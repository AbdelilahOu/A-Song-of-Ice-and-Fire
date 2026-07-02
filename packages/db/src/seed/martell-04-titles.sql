-- Martell titles and relations.

WITH t(slug, title, sy, ey, current_flag) AS (
  VALUES
   ('nymeria','Princess of Dorne',NULL,NULL,0),
   ('mors-martell','Prince of Dorne',NULL,NULL,0),
   ('meria-martell','Princess of Dorne',NULL,13,0),
   ('nymor-martell','Prince of Dorne',13,NULL,0),
   ('moriah-martell','Princess of Dorne',NULL,NULL,0),
   ('maron-martell','Prince of Dorne',187,NULL,0),
   ('doran-martell','Prince of Dorne',NULL,NULL,1),
   ('arianne-martell','Princess of Dorne',276,NULL,1),
   ('lewyn-martell','Kingsguard Knight',NULL,283,0),
   ('oberyn-martell','Prince of Dorne',258,300,0)
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
   ('oberyn-martell','ellaria-sand','paramour','Ellaria was Oberyn''s long-term paramour.'),
   ('trystane-martell','myrcella-baratheon','betrothed','Doran accepted Tyrion''s marriage pact for Trystane and Myrcella.'),
   ('oberyn-martell','elia-martell','sibling','Oberyn sought vengeance for Elia and her children.')
)
INSERT INTO member_relation (from_member_id, to_member_id, type, notes)
SELECT f.id, tt.id, r.type, r.notes
FROM r JOIN member f ON f.slug=r.from_slug JOIN member tt ON tt.slug=r.to_slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_relation mr
  WHERE mr.from_member_id=f.id AND mr.to_member_id=tt.id AND mr.type=r.type
);
