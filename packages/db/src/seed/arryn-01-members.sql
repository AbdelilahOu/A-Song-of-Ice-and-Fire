-- Arryn dynasty seed. Idempotent UPSERT by slug; lineage is wired separately.

INSERT INTO member (slug, name, epithet, house_id, gender, status, is_bastard, born_year, died_year, culture, notable_for)
VALUES
 ('artys-arryn','Artys Arryn','the Winged Knight',(SELECT id FROM house WHERE slug='arryn'),'male','dead',0,NULL,NULL,'Andal','Legendary Andal founder of House Arryn and first King of Mountain and Vale.'),
 ('robar-ii-royce','Robar II Royce',NULL,NULL,'male','dead',0,NULL,NULL,'First Men','Bronze King defeated by Artys Arryn.'),
 ('ronnel-arryn','Ronnel Arryn','the King Who Flew',(SELECT id FROM house WHERE slug='arryn'),'male','dead',0,NULL,NULL,'Valeman','Boy King of Mountain and Vale who bent the knee to Visenya Targaryen.'),
 ('sharra-arryn','Sharra Arryn','the Flower of the Mountain',(SELECT id FROM house WHERE slug='arryn'),'female','dead',0,NULL,NULL,'Valeman','Queen Regent of the Vale during Aegon''s Conquest.'),
 ('hubert-arryn','Hubert Arryn',NULL,(SELECT id FROM house WHERE slug='arryn'),'male','dead',0,NULL,NULL,'Valeman','Contender for the Vale after Ronnel Arryn''s death.'),
 ('arnold-arryn','Arnold Arryn',NULL,(SELECT id FROM house WHERE slug='arryn'),'male','dead',0,NULL,NULL,'Valeman','Rival claimant imprisoned during the reign of Jeyne Arryn.'),
 ('jeyne-arryn','Jeyne Arryn','the Maiden of the Vale',(SELECT id FROM house WHERE slug='arryn'),'female','dead',0,NULL,134,'Valeman','Lady of the Eyrie during the Dance; supported Rhaenyra Targaryen.'),
 ('joffrey-arryn','Joffrey Arryn',NULL,(SELECT id FROM house WHERE slug='arryn'),'male','dead',0,NULL,NULL,'Valeman','Chosen heir of Jeyne Arryn.'),
 ('jesper-arryn','Jesper Arryn',NULL,(SELECT id FROM house WHERE slug='arryn'),'male','dead',0,NULL,NULL,'Valeman','Father of Jon Arryn.'),
 ('jon-arryn','Jon Arryn',NULL,(SELECT id FROM house WHERE slug='arryn'),'male','dead',0,NULL,298,'Valeman','Lord of the Eyrie, Hand of the King, and foster father of Robert Baratheon and Eddard Stark.'),
 ('rowena-arryn','Rowena Arryn',NULL,(SELECT id FROM house WHERE slug='arryn'),'female','dead',0,NULL,NULL,'Valeman','Sister of Jon Arryn.'),
 ('alys-arryn','Alys Arryn',NULL,(SELECT id FROM house WHERE slug='arryn'),'female','dead',0,NULL,NULL,'Valeman','Sister of Jon Arryn and mother of Harrold Hardyng.'),
 ('robert-arryn','Robert Arryn','Sweetrobin',(SELECT id FROM house WHERE slug='arryn'),'male','alive',0,292,NULL,'Valeman','Sickly Lord of the Eyrie after Jon Arryn''s death.'),
 ('lysa-tully','Lysa Tully',NULL,(SELECT id FROM house WHERE slug='tully'),'female','dead',0,266,300,'Riverlander','Wife of Jon Arryn and mother of Robert Arryn.'),
 ('harrold-hardyng','Harrold Hardyng','Harry the Heir',NULL,'male','alive',0,NULL,NULL,'Valeman','Heir presumptive to the Vale after Robert Arryn.'),
 ('petyr-baelish','Petyr Baelish','Littlefinger',NULL,'male','alive',0,268,NULL,'Valeman','Lord Protector of the Vale after marrying Lysa Arryn.'),
 ('ned-stark','Eddard Stark',NULL,(SELECT id FROM house WHERE slug='stark'),'male','dead',0,263,299,'Northmen','Foster son of Jon Arryn and later Hand of the King.'),
 ('robert-baratheon','Robert Baratheon',NULL,(SELECT id FROM house WHERE slug='baratheon'),'male','dead',0,262,298,'Stormlander','Foster son of Jon Arryn and leader of Robert''s Rebellion.')
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
