-- Targaryen dragons and their riders. Idempotent (dragon UPSERT by slug;
-- rider bonds guarded by NOT EXISTS). Notable rider resolved by slug.

WITH d(slug, name, status, size, color, by, dy, rider_slug, fate) AS (
  VALUES
   ('balerion','Balerion','dead','great','black',NULL,94,'aegon-i-targaryen','The Black Dread; last dragon born in Valyria, mount of the Conqueror. Died of old age.'),
   ('vhagar','Vhagar','dead','great','bronze-green',NULL,130,'aemond-targaryen','Ridden by Visenya, Laena, and Aemond; the largest living dragon of the Dance. Slain over the Gods Eye.'),
   ('meraxes','Meraxes','dead','great','silver',NULL,10,'rhaenys-targaryen','Rhaenys the Conqueror''s mount; downed by a scorpion bolt over the Hellholt in Dorne.'),
   ('caraxes','Caraxes','dead','large','red',NULL,130,'daemon-targaryen','The Blood Wyrm; Daemon Targaryen''s fierce red dragon. Died of wounds after killing Vhagar.'),
   ('syrax','Syrax','dead','large','yellow',NULL,130,'rhaenyra-targaryen','Rhaenyra''s golden dragon; torn apart when the mob stormed the Dragonpit.'),
   ('sunfyre','Sunfyre','dead','large','gold',NULL,131,'aegon-ii-targaryen','The Golden; most beautiful of dragons, mount of Aegon II. Devoured Rhaenyra, then died of his wounds.'),
   ('dreamfyre','Dreamfyre','dead','large','pale-blue',NULL,130,'helaena-targaryen','Ridden by Rhaena and then Helaena; slain in the storming of the Dragonpit.'),
   ('vermithor','Vermithor','dead','great','bronze',NULL,130,'jaehaerys-i-targaryen','The Bronze Fury; the Old King''s mount, later claimed by Hugh Hammer. Killed at the Second Battle of Tumbleton.'),
   ('silverwing','Silverwing','unknown','large','silver',NULL,NULL,'alysanne-targaryen','Good Queen Alysanne''s gentle dragon; survived the Dance and was last seen near the God''s Eye.'),
   ('meleys','Meleys','dead','large','red',NULL,129,'rhaenys-queen-who-never-was','The Red Queen; mount of Rhaenys. Slain with her rider at the Battle of Rook''s Rest.'),
   ('seasmoke','Seasmoke','dead','medium','pale-grey',NULL,130,'laenor-velaryon','Laenor Velaryon''s dragon, later claimed by Addam of Hull; fell at the Second Battle of Tumbleton.'),
   ('vermax','Vermax','dead','medium','green',NULL,130,'jacaerys-velaryon','Jacaerys Velaryon''s mount; died with his rider in the Battle of the Gullet.'),
   ('arrax','Arrax','dead','small','white',NULL,129,'lucerys-velaryon','Lucerys Velaryon''s young dragon; killed by Vhagar over Storm''s End, the spark of the Dance.'),
   ('tyraxes','Tyraxes','dead','small','unknown',NULL,130,'joffrey-velaryon','Joffrey Velaryon''s dragon; slain in his pit when the mob stormed the Dragonpit.'),
   ('tessarion','Tessarion','dead','medium','cobalt',NULL,130,'daeron-targaryen-daring','The Blue Queen; Daeron the Daring''s mount, lost at the Second Battle of Tumbleton.'),
   ('moondancer','Moondancer','dead','small','pale-green',NULL,130,'baela-targaryen','Baela Targaryen''s young dragon; died grappling Sunfyre in the Battle of the Gullet.'),
   ('morning','Morning','alive','hatchling','pink-black',129,NULL,'rhaena-targaryen-morning','Rhaena''s dragon, hatched at the war''s end; one of the last dragons of the age.'),
   ('stormcloud','Stormcloud','dead','small','pale-grey',NULL,130,'aegon-iii-targaryen','Bore the boy Aegon III to safety at Dragonstone, dying of his wounds soon after.'),
   ('drogon','Drogon','alive','large','black-red',298,NULL,'daenerys-targaryen','Named for Khal Drogo; the largest and fiercest of Daenerys''s three dragons.'),
   ('rhaegal','Rhaegal','alive','medium','green-bronze',298,NULL,NULL,'Named for Rhaegar; one of the three dragons hatched at the Dothraki sea.'),
   ('viserion','Viserion','alive','medium','cream-gold',298,NULL,NULL,'Named for Viserys; cream-and-gold dragon born from the fires of Drogo''s pyre.')
)
INSERT INTO dragon (slug, name, status, size, color, born_year, died_year, notable_rider_id, fate)
SELECT d.slug, d.name, d.status, d.size, d.color, d.by, d.dy,
       (SELECT id FROM member WHERE slug=d.rider_slug), d.fate
FROM d
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name, status=excluded.status, size=excluded.size, color=excluded.color,
  born_year=COALESCE(excluded.born_year, dragon.born_year),
  died_year=COALESCE(excluded.died_year, dragon.died_year),
  notable_rider_id=COALESCE(excluded.notable_rider_id, dragon.notable_rider_id),
  fate=excluded.fate, updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

-- Rider bonds (a dragon may have several riders across its life).
WITH b(dragon_slug, rider_slug, notable) AS (
  VALUES
   ('balerion','aegon-i-targaryen',1),
   ('balerion','maegor-i-targaryen',0),
   ('balerion','viserys-i-targaryen',0),
   ('vhagar','visenya-targaryen',0),
   ('vhagar','laena-velaryon',0),
   ('vhagar','aemond-targaryen',1),
   ('meraxes','rhaenys-targaryen',1),
   ('caraxes','aemon-targaryen-prince',0),
   ('caraxes','daemon-targaryen',1),
   ('syrax','rhaenyra-targaryen',1),
   ('sunfyre','aegon-ii-targaryen',1),
   ('dreamfyre','rhaena-targaryen',0),
   ('dreamfyre','helaena-targaryen',1),
   ('vermithor','jaehaerys-i-targaryen',1),
   ('silverwing','alysanne-targaryen',1),
   ('meleys','rhaenys-queen-who-never-was',1),
   ('seasmoke','laenor-velaryon',1),
   ('vermax','jacaerys-velaryon',1),
   ('arrax','lucerys-velaryon',1),
   ('tyraxes','joffrey-velaryon',1),
   ('tessarion','daeron-targaryen-daring',1),
   ('moondancer','baela-targaryen',1),
   ('morning','rhaena-targaryen-morning',1),
   ('stormcloud','aegon-iii-targaryen',1),
   ('drogon','daenerys-targaryen',1)
)
INSERT INTO dragon_rider (dragon_id, member_id, is_notable)
SELECT dr.id, m.id, b.notable
FROM b JOIN dragon dr ON dr.slug=b.dragon_slug JOIN member m ON m.slug=b.rider_slug
WHERE NOT EXISTS (
  SELECT 1 FROM dragon_rider x WHERE x.dragon_id=dr.id AND x.member_id=m.id
);
