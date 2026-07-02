-- Martell house metadata and relations.

UPDATE house
SET founder_id=(SELECT id FROM member WHERE slug='mors-martell'),
    current_lord_id=(SELECT id FROM member WHERE slug='doran-martell'),
    updated_at=(cast(unixepoch('subsecond') * 1000 as integer))
WHERE slug='martell';

WITH rel(a_slug, b_slug, type, sy, ey, current_flag, descr) AS (
  VALUES
   ('martell','targaryen','war',1,187,0,'Dorne resisted Targaryen conquest for nearly two centuries.'),
   ('martell','targaryen','marriage_pact',168,NULL,0,'Myriah Martell and later Daenerys Targaryen sealed Dorne''s union with the realm.'),
   ('martell','lannister','feud',283,NULL,1,'The murder of Elia and her children made House Lannister a blood enemy.'),
   ('martell','tyrell','rivalry',NULL,NULL,1,'Dorne and the Reach share a long frontier rivalry.'),
   ('martell','baratheon','marriage_pact',299,NULL,1,'Trystane Martell was betrothed to Myrcella Baratheon.')
)
INSERT INTO house_relation (house_a_id, house_b_id, type, start_year, end_year, is_current, description)
SELECT a.id, b.id, rel.type, rel.sy, rel.ey, rel.current_flag, rel.descr
FROM rel JOIN house a ON a.slug=rel.a_slug JOIN house b ON b.slug=rel.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM house_relation hr
  WHERE hr.house_a_id=a.id AND hr.house_b_id=b.id AND hr.type=rel.type
);
