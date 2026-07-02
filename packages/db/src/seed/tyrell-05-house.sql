-- Tyrell house metadata and relations.

UPDATE house
SET founder_id=(SELECT id FROM member WHERE slug='garlan-tyrell-first'),
    current_lord_id=(SELECT id FROM member WHERE slug='mace-tyrell'),
    updated_at=(cast(unixepoch('subsecond') * 1000 as integer))
WHERE slug='tyrell';

WITH rel(a_slug, b_slug, type, sy, ey, current_flag, descr) AS (
  VALUES
   ('tyrell','targaryen','vassalage',1,283,0,'Aegon I raised the Tyrells after the Gardener kings died.'),
   ('tyrell','baratheon','marriage_pact',299,299,0,'Margaery married Renly Baratheon.'),
   ('tyrell','lannister','alliance',299,NULL,1,'The Tyrells allied with the Lannisters after Renly''s death.'),
   ('tyrell','martell','rivalry',NULL,NULL,1,'The Reach and Dorne share a long border rivalry.')
)
INSERT INTO house_relation (house_a_id, house_b_id, type, start_year, end_year, is_current, description)
SELECT a.id, b.id, rel.type, rel.sy, rel.ey, rel.current_flag, rel.descr
FROM rel JOIN house a ON a.slug=rel.a_slug JOIN house b ON b.slug=rel.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM house_relation hr
  WHERE hr.house_a_id=a.id AND hr.house_b_id=b.id AND hr.type=rel.type
);
