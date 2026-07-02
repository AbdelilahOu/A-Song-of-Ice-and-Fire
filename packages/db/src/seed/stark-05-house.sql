-- Stark house metadata and relations.

UPDATE house
SET founder_id=(SELECT id FROM member WHERE slug='brandon-the-builder'),
    current_lord_id=(SELECT id FROM member WHERE slug='bran-stark'),
    updated_at=(cast(unixepoch('subsecond') * 1000 as integer))
WHERE slug='stark';

WITH rel(a_slug, b_slug, type, sy, ey, current_flag, descr) AS (
  VALUES
   ('stark','targaryen','vassalage',1,282,0,'Torrhen Stark knelt to Aegon I, ending the Kings in the North.'),
   ('stark','baratheon','alliance',282,283,0,'Eddard Stark and Robert Baratheon led the rebellion against Aerys II.'),
   ('stark','tully','marriage_pact',283,NULL,1,'Eddard Stark married Catelyn Tully.'),
   ('stark','arryn','alliance',282,283,0,'Jon Arryn fostered Eddard and joined the rebellion.'),
   ('stark','lannister','war',298,300,0,'The Starks and Lannisters fought during the War of the Five Kings.'),
   ('stark','greyjoy','war',299,NULL,1,'The ironborn invaded the North during the War of the Five Kings.')
)
INSERT INTO house_relation (house_a_id, house_b_id, type, start_year, end_year, is_current, description)
SELECT a.id, b.id, rel.type, rel.sy, rel.ey, rel.current_flag, rel.descr
FROM rel JOIN house a ON a.slug=rel.a_slug JOIN house b ON b.slug=rel.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM house_relation hr
  WHERE hr.house_a_id=a.id AND hr.house_b_id=b.id AND hr.type=rel.type
);
