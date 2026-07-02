-- Greyjoy dynasty seed. Idempotent UPSERT by slug; lineage is wired separately.

INSERT INTO member (slug, name, epithet, house_id, gender, status, is_bastard, born_year, died_year, culture, notable_for)
VALUES
 ('grey-king','The Grey King',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,NULL,NULL,'Ironborn','Mythic ancestor claimed by House Greyjoy and the ironborn.'),
 ('vickon-greyjoy','Vickon Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,NULL,NULL,'Ironborn','Chosen by the ironborn as lord after Aegon destroyed House Hoare.'),
 ('dalton-greyjoy','Dalton Greyjoy','the Red Kraken',(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,114,133,'Ironborn','Lord Reaper of Pyke during the Dance, famous raider of the westerlands.'),
 ('veron-greyjoy','Veron Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,NULL,NULL,'Ironborn','Later Lord Reaper of Pyke in the Targaryen era.'),
 ('dagon-greyjoy','Dagon Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,NULL,NULL,'Ironborn','Lord Reaper who raided the western coast in the reign of Aerys I.'),
 ('loron-greyjoy','Loron Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,NULL,NULL,'Ironborn','Lord Reaper of Pyke after Dagon Greyjoy.'),
 ('quellon-greyjoy','Quellon Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,NULL,283,'Ironborn','Reforming Lord Reaper of Pyke and father of Balon, Euron, Victarion, Urrigon, Aeron, and Robin.'),
 ('balon-greyjoy','Balon Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,255,299,'Ironborn','Lord Reaper of Pyke who twice crowned himself king.'),
 ('alannys-harlaw','Alannys Harlaw',NULL,NULL,'female','alive',0,NULL,NULL,'Ironborn','Wife of Balon Greyjoy and mother of his children.'),
 ('euron-greyjoy','Euron Greyjoy','Crow''s Eye',(SELECT id FROM house WHERE slug='greyjoy'),'male','alive',0,256,NULL,'Ironborn','Exiled brother of Balon who returned to claim the Seastone Chair.'),
 ('victarion-greyjoy','Victarion Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','alive',0,257,NULL,'Ironborn','Lord Captain of the Iron Fleet.'),
 ('urrigon-greyjoy','Urrigon Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,NULL,NULL,'Ironborn','Brother of Balon who died after a botched finger dance wound.'),
 ('aeron-greyjoy','Aeron Greyjoy','Damphair',(SELECT id FROM house WHERE slug='greyjoy'),'male','alive',0,269,NULL,'Ironborn','Priest of the Drowned God and brother of Balon.'),
 ('robin-greyjoy','Robin Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,NULL,NULL,'Ironborn','Youngest son of Quellon Greyjoy.'),
 ('rodrik-greyjoy','Rodrik Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,276,289,'Ironborn','Eldest son of Balon, killed during the Greyjoy Rebellion.'),
 ('maron-greyjoy','Maron Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,277,289,'Ironborn','Second son of Balon, killed at Pyke during the Greyjoy Rebellion.'),
 ('asha-greyjoy','Asha Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'female','alive',0,275,NULL,'Ironborn','Daughter of Balon and claimant in the kingsmoot.'),
 ('theon-greyjoy','Theon Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','alive',0,278,NULL,'Ironborn','Heir of Balon, ward of Eddard Stark, and captor of Winterfell.'),
 ('quenton-greyjoy','Quenton Greyjoy',NULL,(SELECT id FROM house WHERE slug='greyjoy'),'male','dead',0,NULL,NULL,'Ironborn','Brother of Balon from Quellon''s third marriage.'),
 ('ned-stark','Eddard Stark',NULL,(SELECT id FROM house WHERE slug='stark'),'male','dead',0,263,299,'Northmen','Took Theon Greyjoy as ward after Balon''s first rebellion.'),
 ('robert-baratheon','Robert Baratheon',NULL,(SELECT id FROM house WHERE slug='baratheon'),'male','dead',0,262,298,'Stormlander','King who crushed the Greyjoy Rebellion.'),
 ('stannis-baratheon','Stannis Baratheon',NULL,(SELECT id FROM house WHERE slug='baratheon'),'male','alive',0,264,NULL,'Stormlander','Destroyed the Iron Fleet off Fair Isle during the Greyjoy Rebellion.')
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
