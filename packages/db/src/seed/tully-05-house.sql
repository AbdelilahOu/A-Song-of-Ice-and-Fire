-- Tully house metadata and relations.

UPDATE house
SET current_lord_id=(SELECT id FROM member WHERE slug='edmure-tully'),
    updated_at=(cast(unixepoch('subsecond') * 1000 as integer))
WHERE slug='tully';

WITH rel(a_slug, b_slug, type, sy, ey, current_flag, descr) AS (
  VALUES
   ('tully','targaryen','vassalage',1,283,0,'House Tully became Lords Paramount of the Trident under Aegon I.'),
   ('tully','stark','marriage_pact',283,NULL,1,'Catelyn Tully married Eddard Stark.'),
   ('tully','arryn','marriage_pact',283,298,0,'Lysa Tully married Jon Arryn.'),
   ('tully','lannister','war',298,300,0,'The riverlands were invaded by Lannister forces during the War of the Five Kings.'),
   ('tully','baratheon','alliance',282,283,0,'Hoster Tully joined Robert''s Rebellion through marriage alliances.')
)
INSERT INTO house_relation (house_a_id, house_b_id, type, start_year, end_year, is_current, description)
SELECT a.id, b.id, rel.type, rel.sy, rel.ey, rel.current_flag, rel.descr
FROM rel JOIN house a ON a.slug=rel.a_slug JOIN house b ON b.slug=rel.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM house_relation hr
  WHERE hr.house_a_id=a.id AND hr.house_b_id=b.id AND hr.type=rel.type
);
