-- Arryn house metadata and relations.

UPDATE house
SET founder_id=(SELECT id FROM member WHERE slug='artys-arryn'),
    current_lord_id=(SELECT id FROM member WHERE slug='robert-arryn'),
    updated_at=(cast(unixepoch('subsecond') * 1000 as integer))
WHERE slug='arryn';

WITH rel(a_slug, b_slug, type, sy, ey, current_flag, descr) AS (
  VALUES
   ('arryn','targaryen','vassalage',1,283,0,'Ronnel Arryn bent the knee to Visenya Targaryen.'),
   ('arryn','baratheon','alliance',282,283,0,'Jon Arryn called his banners for Robert Baratheon.'),
   ('arryn','stark','alliance',282,283,0,'Jon Arryn allied with his foster son Eddard Stark.'),
   ('arryn','tully','marriage_pact',283,298,0,'Jon Arryn married Lysa Tully as part of the rebel alliance.')
)
INSERT INTO house_relation (house_a_id, house_b_id, type, start_year, end_year, is_current, description)
SELECT a.id, b.id, rel.type, rel.sy, rel.ey, rel.current_flag, rel.descr
FROM rel JOIN house a ON a.slug=rel.a_slug JOIN house b ON b.slug=rel.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM house_relation hr
  WHERE hr.house_a_id=a.id AND hr.house_b_id=b.id AND hr.type=rel.type
);
