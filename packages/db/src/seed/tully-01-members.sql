-- Tully dynasty seed. Idempotent UPSERT by slug; lineage is wired separately.

INSERT INTO member (slug, name, epithet, house_id, gender, status, is_bastard, born_year, died_year, culture, notable_for)
VALUES
 ('edmure-tully-ancestor','Edmure Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'male','dead',0,NULL,NULL,'Riverlander','First Lord Paramount of the Trident after Aegon''s Conquest.'),
 ('axel-tully','Axel Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'male','dead',0,NULL,NULL,'Riverlander','Lord of Riverrun during the Faith Militant era.'),
 ('grover-tully','Grover Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'male','dead',0,NULL,130,'Riverlander','Aged Lord of Riverrun at the start of the Dance of the Dragons.'),
 ('elmo-tully','Elmo Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'male','dead',0,NULL,130,'Riverlander','Lord of Riverrun after Grover; declared for Rhaenyra before dying suddenly.'),
 ('kermit-tully','Kermit Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'male','dead',0,NULL,NULL,'Riverlander','Young Lord of Riverrun who led the riverlords for the blacks.'),
 ('oscar-tully','Oscar Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'male','dead',0,NULL,NULL,'Riverlander','Brother of Kermit and a notable commander in the Dance.'),
 ('medgar-tully','Medgar Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'male','dead',0,NULL,NULL,'Riverlander','Later Lord of Riverrun in the Targaryen era.'),
 ('hoster-tully','Hoster Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'male','dead',0,243,299,'Riverlander','Lord of Riverrun who joined Robert''s Rebellion through marriage alliances.'),
 ('brynden-tully','Brynden Tully','the Blackfish',(SELECT id FROM house WHERE slug='tully'),'male','alive',0,245,NULL,'Riverlander','Brother of Hoster and famed knight of the riverlands.'),
 ('minisa-whent','Minisa Whent',NULL,NULL,'female','dead',0,NULL,NULL,'Riverlander','Wife of Hoster Tully and mother of Catelyn, Lysa, and Edmure.'),
 ('catelyn-tully','Catelyn Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'female','dead',0,264,299,'Riverlander','Daughter of Hoster; wife of Eddard Stark and mother of Robb Stark.'),
 ('lysa-tully','Lysa Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'female','dead',0,266,300,'Riverlander','Daughter of Hoster; wife of Jon Arryn and mother of Robert Arryn.'),
 ('edmure-tully','Edmure Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'male','alive',0,274,NULL,'Riverlander','Lord of Riverrun during the War of the Five Kings.'),
 ('roslin-frey','Roslin Frey',NULL,NULL,'female','alive',0,283,NULL,'Riverlander','Wife of Edmure Tully after the Red Wedding pact.'),
 ('ned-stark','Eddard Stark',NULL,(SELECT id FROM house WHERE slug='stark'),'male','dead',0,263,299,'Northmen','Lord of Winterfell and husband of Catelyn Tully.'),
 ('jon-arryn','Jon Arryn',NULL,(SELECT id FROM house WHERE slug='arryn'),'male','dead',0,NULL,298,'Valeman','Lord of the Eyrie, foster father to Robert and Eddard, and husband of Lysa Tully.'),
 ('robb-stark','Robb Stark',NULL,(SELECT id FROM house WHERE slug='stark'),'male','dead',0,283,299,'Northmen','King in the North and Trident during the War of the Five Kings.'),
 ('robert-arryn','Robert Arryn','Sweetrobin',(SELECT id FROM house WHERE slug='arryn'),'male','alive',0,292,NULL,'Valeman','Sickly Lord of the Eyrie, son of Jon Arryn and Lysa Tully.'),
 ('walder-frey','Walder Frey','the Late Lord',NULL,'male','alive',0,208,NULL,'Riverlander','Lord of the Crossing whose betrayal destroyed Robb Stark''s cause.'),
 ('petyr-baelish','Petyr Baelish','Littlefinger',NULL,'male','alive',0,268,NULL,'Valeman','Master manipulator who loved Catelyn and murdered Lysa.')
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name,
  epithet=COALESCE(excluded.epithet, member.epithet),
  house_id=COALESCE(excluded.house_id, member.house_id),
  gender=excluded.gender,
  status=excluded.status,
  is_bastard=excluded.is_bastard,
  born_year=COALESCE(excluded.born_year, member.born_year),
  died_year=COALESCE(excluded.died_year, member.died_year),
  culture=COALESCE(excluded.culture, member.culture),
  notable_for=COALESCE(excluded.notable_for, member.notable_for),
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));
