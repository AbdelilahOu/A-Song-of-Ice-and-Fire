-- Baratheon house metadata and relations.

UPDATE house
SET founder_id=(SELECT id FROM member WHERE slug='orys-baratheon'),
    current_lord_id=(SELECT id FROM member WHERE slug='stannis-baratheon'),
    updated_at=(cast(unixepoch('subsecond') * 1000 as integer))
WHERE slug='baratheon';

WITH rel(a_slug, b_slug, type, sy, ey, current_flag, descr) AS (
  VALUES
   ('baratheon','targaryen','vassalage',1,282,0,'House Baratheon held Storm''s End under the Iron Throne until Robert''s Rebellion.'),
   ('baratheon','stark','alliance',282,283,0,'Robert Baratheon and Eddard Stark led the rebel coalition against Aerys II.'),
   ('baratheon','arryn','alliance',282,283,0,'Jon Arryn joined his foster sons Robert and Eddard in rebellion.'),
   ('baratheon','lannister','marriage_pact',284,298,0,'Robert married Cersei Lannister after the rebellion.'),
   ('baratheon','tyrell','marriage_pact',299,299,0,'Renly married Margaery Tyrell to secure the Reach.')
)
INSERT INTO house_relation (house_a_id, house_b_id, type, start_year, end_year, is_current, description)
SELECT a.id, b.id, rel.type, rel.sy, rel.ey, rel.current_flag, rel.descr
FROM rel JOIN house a ON a.slug=rel.a_slug JOIN house b ON b.slug=rel.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM house_relation hr
  WHERE hr.house_a_id=a.id AND hr.house_b_id=b.id AND hr.type=rel.type
);
