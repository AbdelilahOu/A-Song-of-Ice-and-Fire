-- Greyjoy house metadata and relations.

UPDATE house
SET founder_id=(SELECT id FROM member WHERE slug='grey-king'),
    current_lord_id=(SELECT id FROM member WHERE slug='euron-greyjoy'),
    updated_at=(cast(unixepoch('subsecond') * 1000 as integer))
WHERE slug='greyjoy';

WITH rel(a_slug, b_slug, type, sy, ey, current_flag, descr) AS (
  VALUES
   ('greyjoy','targaryen','vassalage',1,283,0,'The Greyjoys were chosen to rule the Iron Islands under the Iron Throne.'),
   ('greyjoy','lannister','war',129,133,0,'Dalton Greyjoy raided the westerlands during and after the Dance.'),
   ('greyjoy','baratheon','war',289,289,0,'Balon Greyjoy rebelled against Robert Baratheon.'),
   ('greyjoy','stark','war',299,NULL,1,'Theon took Winterfell and the ironborn invaded the North.')
)
INSERT INTO house_relation (house_a_id, house_b_id, type, start_year, end_year, is_current, description)
SELECT a.id, b.id, rel.type, rel.sy, rel.ey, rel.current_flag, rel.descr
FROM rel JOIN house a ON a.slug=rel.a_slug JOIN house b ON b.slug=rel.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM house_relation hr
  WHERE hr.house_a_id=a.id AND hr.house_b_id=b.id AND hr.type=rel.type
);
