-- Tyrell dynasty seed. Idempotent UPSERT by slug; lineage is wired separately.

INSERT INTO member (slug, name, epithet, house_id, gender, status, is_bastard, born_year, died_year, culture, notable_for)
VALUES
 ('garlan-tyrell-first','Garlan Tyrell',NULL,(SELECT id FROM house WHERE slug='tyrell'),'male','dead',0,NULL,NULL,'Reach','Legendary founder of House Tyrell and steward of Highgarden.'),
 ('harlen-tyrell','Harlen Tyrell',NULL,(SELECT id FROM house WHERE slug='tyrell'),'male','dead',0,NULL,NULL,'Reach','Steward of Highgarden raised by Aegon I as Lord Paramount of the Mander.'),
 ('theo-tyrell','Theo Tyrell',NULL,(SELECT id FROM house WHERE slug='tyrell'),'male','dead',0,NULL,NULL,'Reach','Lord of Highgarden during the Dance, whose mother ruled as regent.'),
 ('matthos-tyrell','Matthos Tyrell',NULL,(SELECT id FROM house WHERE slug='tyrell'),'male','dead',0,NULL,NULL,'Reach','Lord of Highgarden in the late Targaryen era.'),
 ('leo-tyrell-longthorn','Leo Tyrell','Longthorn',(SELECT id FROM house WHERE slug='tyrell'),'male','dead',0,NULL,NULL,'Reach','Lord of Highgarden famed as a tourney knight.'),
 ('lorna-tyrell','Lorna Tyrell',NULL,(SELECT id FROM house WHERE slug='tyrell'),'female','dead',0,NULL,NULL,'Reach','Daughter of Leo Longthorn and wife of Lord Beron Stark.'),
 ('luthor-tyrell','Luthor Tyrell',NULL,(SELECT id FROM house WHERE slug='tyrell'),'male','dead',0,NULL,281,'Reach','Lord of Highgarden and husband of Olenna Redwyne.'),
 ('olenna-redwyne','Olenna Redwyne','the Queen of Thorns',NULL,'female','alive',0,228,NULL,'Reach','Matriarch of House Tyrell through marriage to Luthor.'),
 ('mace-tyrell','Mace Tyrell',NULL,(SELECT id FROM house WHERE slug='tyrell'),'male','alive',0,256,NULL,'Reach','Lord of Highgarden during Robert''s Rebellion and the War of the Five Kings.'),
 ('alerie-hightower','Alerie Hightower',NULL,NULL,'female','alive',0,NULL,NULL,'Reach','Wife of Mace Tyrell.'),
 ('willas-tyrell','Willas Tyrell',NULL,(SELECT id FROM house WHERE slug='tyrell'),'male','alive',0,273,NULL,'Reach','Heir to Highgarden, crippled in a tourney accident.'),
 ('garlan-tyrell','Garlan Tyrell','the Gallant',(SELECT id FROM house WHERE slug='tyrell'),'male','alive',0,276,NULL,'Reach','Second son of Mace Tyrell and skilled swordsman.'),
 ('loras-tyrell','Loras Tyrell','the Knight of Flowers',(SELECT id FROM house WHERE slug='tyrell'),'male','alive',0,282,NULL,'Reach','Youngest son of Mace and famed knight; lover of Renly Baratheon.'),
 ('margaery-tyrell','Margaery Tyrell',NULL,(SELECT id FROM house WHERE slug='tyrell'),'female','dead',0,283,300,'Reach','Queen through marriages to Renly, Joffrey, and Tommen.'),
 ('leonette-fossoway','Leonette Fossoway',NULL,NULL,'female','alive',0,NULL,NULL,'Reach','Wife of Garlan Tyrell.'),
 ('renly-baratheon','Renly Baratheon',NULL,(SELECT id FROM house WHERE slug='baratheon'),'male','dead',0,277,299,'Stormlander','Baratheon claimant backed by House Tyrell.'),
 ('joffrey-baratheon','Joffrey Baratheon',NULL,(SELECT id FROM house WHERE slug='baratheon'),'male','dead',0,286,300,'Westermen','King married to Margaery Tyrell before his poisoning.'),
 ('tommen-baratheon','Tommen Baratheon',NULL,(SELECT id FROM house WHERE slug='baratheon'),'male','alive',0,291,NULL,'Westermen','Young king married to Margaery Tyrell.'),
 ('randyll-tarly','Randyll Tarly',NULL,NULL,'male','alive',0,NULL,NULL,'Reach','Major Tyrell bannerman and victor over Robert at Ashford.')
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
