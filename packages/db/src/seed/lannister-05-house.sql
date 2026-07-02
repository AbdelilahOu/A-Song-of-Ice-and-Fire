-- Lannister house metadata and selected house relations. Idempotent.

UPDATE house
SET founder_id=(SELECT id FROM member WHERE slug='lann-the-clever'),
    current_lord_id=(SELECT id FROM member WHERE slug='cersei-lannister'),
    updated_at=(cast(unixepoch('subsecond') * 1000 as integer))
WHERE slug='lannister';

WITH rel(a_slug, b_slug, type, sy, ey, current_flag, descr) AS (
  VALUES
   ('lannister','targaryen','vassalage',1,283,0,'Loren I bent the knee after the Field of Fire, making House Lannister wardens under the Iron Throne.'),
   ('lannister','baratheon','marriage_pact',284,298,0,'Cersei Lannister married Robert Baratheon after Robert''s Rebellion.'),
   ('lannister','stark','war',298,300,0,'House Lannister and House Stark fought on opposite sides of the War of the Five Kings.'),
   ('lannister','tully','war',298,300,0,'The Lannister invasion of the riverlands made House Tully a major enemy in the War of the Five Kings.'),
   ('lannister','tyrell','alliance',300,NULL,1,'The royal regime was stabilized by the Lannister-Tyrell alliance after the Battle of the Blackwater.')
)
INSERT INTO house_relation (house_a_id, house_b_id, type, start_year, end_year, is_current, description)
SELECT a.id, b.id, rel.type, rel.sy, rel.ey, rel.current_flag, rel.descr
FROM rel JOIN house a ON a.slug=rel.a_slug JOIN house b ON b.slug=rel.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM house_relation hr
  WHERE hr.house_a_id=a.id AND hr.house_b_id=b.id AND hr.type=rel.type
);
