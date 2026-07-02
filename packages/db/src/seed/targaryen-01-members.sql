-- Targaryen dynasty — full timeline spine (Fire & Blood era through the main saga).
-- Idempotent: UPSERT by slug. Parent (father/mother) links are applied separately
-- in targaryen-02-lineage.sql so insertion order here does not matter.
-- Year epoch: negative = Before Conquest (BC), positive = After Conquest (AC).

-- Helper note: house_id resolved by subquery so this is portable.

INSERT INTO member (slug, name, epithet, house_id, gender, status, born_year, died_year, culture, notable_for)
VALUES
 -- Pre-Conquest / Conquest generation (some already created via MCP; re-stated for completeness)
 ('aerion-targaryen','Aerion Targaryen','Lord of Dragonstone',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',NULL,NULL,'Valyrian','Lord of Dragonstone; father of Aegon the Conqueror, Visenya, and Rhaenys.'),
 ('valaena-velaryon','Valaena',NULL,NULL,'female','dead',NULL,NULL,'Valyrian','Of House Velaryon; mother of Aegon the Conqueror, Visenya, and Rhaenys.'),

 -- Jaehaerys I & Alysanne generation extras
 ('jocelyn-baratheon','Jocelyn',NULL,(SELECT id FROM house WHERE slug='baratheon'),'female','dead',36,NULL,'Andal','Baratheon wife of Prince Aemon; mother of Rhaenys, the Queen Who Never Was.'),
 ('daella-targaryen','Daella Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'female','dead',64,82,'Valyrian','Gentle daughter of Jaehaerys I and Alysanne; mother of Queen Aemma Arryn.'),

 -- Fifth generation: Viserys I, Daemon, and consorts
 ('viserys-i-targaryen','Viserys I Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'male','dead',77,129,'Valyrian','Fifth Targaryen king (103-129 AC); last rider of Balerion. His choice of heir sparked the Dance of the Dragons.'),
 ('daemon-targaryen','Daemon Targaryen','the Rogue Prince',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',81,130,'Valyrian','Rider of Caraxes and consort of Rhaenyra; a warrior prince who died slaying Aemond above the Gods Eye.'),
 ('aemma-arryn','Aemma','of House Arryn',(SELECT id FROM house WHERE slug='arryn'),'female','dead',82,105,'Andal','First wife of Viserys I and mother of Rhaenyra; died in childbirth.'),
 ('alicent-hightower','Alicent','of House Hightower',NULL,'female','dead',88,133,'Andal','Second wife of Viserys I; mother of Aegon II and leader of the greens in the Dance.'),
 ('rhaenys-queen-who-never-was','Rhaenys Targaryen','the Queen Who Never Was',(SELECT id FROM house WHERE slug='targaryen'),'female','dead',74,129,'Valyrian','Daughter of Prince Aemon, passed over for the throne twice; rider of Meleys, died at Rook''s Rest.'),
 ('corlys-velaryon','Corlys','the Sea Snake',NULL,'male','dead',53,132,'Valyrian','Lord of the Tides, greatest seafarer of his age; Hand of the King and pillar of the blacks.'),

 -- Sixth generation: the Dance principals
 ('rhaenyra-targaryen','Rhaenyra Targaryen','the Realm''s Delight',(SELECT id FROM house WHERE slug='targaryen'),'female','dead',97,130,'Valyrian','Named heir by Viserys I; rider of Syrax and queen of the blacks in the Dance. Devoured by Sunfyre on Dragonstone.'),
 ('aegon-ii-targaryen','Aegon II Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'male','dead',107,131,'Valyrian','Crowned over his half-sister to launch the Dance; rider of Sunfyre. Poisoned at war''s end.'),
 ('helaena-targaryen','Helaena Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'female','dead',109,130,'Valyrian','Sister-wife of Aegon II, rider of Dreamfyre; broken by the murder of her son, she took her own life.'),
 ('aemond-targaryen','Aemond Targaryen','One-Eye',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',110,130,'Valyrian','One-eyed prince who claimed Vhagar, the greatest dragon of the age; slain by Daemon over the Gods Eye.'),
 ('daeron-targaryen-daring','Daeron Targaryen','the Daring',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',114,130,'Valyrian','Youngest son of Viserys I, rider of Tessarion; a hero of the greens, slain at the Second Battle of Tumbleton.'),
 ('laenor-velaryon','Laenor','Velaryon',NULL,'male','dead',94,120,'Valyrian','First husband of Rhaenyra, rider of Seasmoke.'),
 ('laena-velaryon','Laena','Velaryon',NULL,'female','dead',92,120,'Valyrian','Wife of Daemon Targaryen, rider of Vhagar; died in childbirth on Driftmark.'),

 -- Rhaenyra's children
 ('jacaerys-velaryon','Jacaerys Velaryon','Jace',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',114,130,'Valyrian','Heir to Rhaenyra, rider of Vermax; fell in the Battle of the Gullet.'),
 ('lucerys-velaryon','Lucerys Velaryon','Luke',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',115,129,'Valyrian','Rider of Arrax; his death over Storm''s End at Vhagar''s jaws ignited the Dance.'),
 ('joffrey-velaryon','Joffrey Velaryon',NULL,(SELECT id FROM house WHERE slug='targaryen'),'male','dead',117,130,'Valyrian','Youngest of Rhaenyra''s Velaryon sons, rider of Tyraxes; died in the storming of the Dragonpit.'),
 ('aegon-iii-targaryen','Aegon III Targaryen','the Dragonbane',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',120,157,'Valyrian','Son of Rhaenyra and Daemon; his reign saw the last Targaryen dragons wither and die.'),
 ('viserys-ii-targaryen','Viserys II Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'male','dead',125,172,'Valyrian','Younger son of Rhaenyra; a capable Hand who ruled in all but name before his brief kingship.'),

 -- Aegon II's children
 ('jaehaerys-targaryen-son','Jaehaerys Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'male','dead',122,130,'Valyrian','Son and heir of Aegon II, murdered by Blood and Cheese.'),
 ('jaehaera-targaryen','Jaehaera Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'female','dead',123,133,'Valyrian','Daughter of Aegon II; wed to Aegon III to seal the peace, she died young.'),

 -- Daemon's daughters by Laena
 ('baela-targaryen','Baela Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'female','dead',116,162,'Valyrian','Daughter of Daemon and Laena, rider of Moondancer; wed Alyn Velaryon.'),
 ('rhaena-targaryen-morning','Rhaena Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'female','dead',116,171,'Valyrian','Twin of Baela; the last dragon of the age, Morning, hatched from her egg.'),
 ('daenaera-velaryon','Daenaera','Velaryon',NULL,'female','dead',145,NULL,'Valyrian','Second wife of Aegon III, chosen at a great ball; mother of Daeron I and Baelor I.'),

 -- Post-Dance kings and their kin
 ('daeron-i-targaryen','Daeron I Targaryen','the Young Dragon',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',143,161,'Valyrian','Boy-king who conquered Dorne at fourteen; slain there under a peace banner.'),
 ('baelor-i-targaryen','Baelor I Targaryen','the Blessed',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',144,171,'Valyrian','Septon King whose piety and fasting shaped and ended his reign.'),
 ('daena-targaryen','Daena Targaryen','the Defiant',(SELECT id FROM house WHERE slug='targaryen'),'female','dead',145,171,'Valyrian','Wilful sister-wife of Baelor I; mother of the bastard Daemon Blackfyre.'),
 ('aegon-iv-targaryen','Aegon IV Targaryen','the Unworthy',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',135,184,'Valyrian','A gluttonous, faithless king whose deathbed legitimization of his bastards sowed the Blackfyre Rebellions.'),
 ('naerys-targaryen','Naerys Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'female','dead',138,179,'Valyrian','Pious sister-wife of Aegon IV and mother of Daeron II.'),
 ('aemon-dragonknight','Aemon Targaryen','the Dragonknight',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',136,178,'Valyrian','Kingsguard knight and champion of his sister Naerys; a paragon of chivalry.'),

 -- Great Bastards of Aegon IV
 ('daemon-blackfyre','Daemon Blackfyre','the Black Dragon',NULL,'male','dead',170,196,'Valyrian','Bastard son of Aegon IV, gifted the sword Blackfyre and legitimized; founder of House Blackfyre, slain at the Redgrass Field.'),
 ('aegor-rivers','Aegor Rivers','Bittersteel',NULL,'male','dead',172,NULL,'Valyrian','Great Bastard of Aegon IV; founded the Golden Company and waged the Blackfyre Rebellions in exile.'),
 ('brynden-rivers','Brynden Rivers','Bloodraven',NULL,'male','unknown',175,252,'Valyrian','Albino sorcerer-bastard of Aegon IV; Hand of the King, then Lord Commander of the Night''s Watch, and at last the last greenseer.'),

 -- Daeron II line
 ('daeron-ii-targaryen','Daeron II Targaryen','the Good',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',153,209,'Valyrian','Wise king who brought Dorne into the realm by marriage; weathered the First Blackfyre Rebellion.'),
 ('myriah-martell','Myriah','Nymeros Martell',(SELECT id FROM house WHERE slug='martell'),'female','dead',152,209,'Dornish','Dornish princess wed to Daeron II, sealing Dorne''s union with the Iron Throne.'),
 ('baelor-breakspear','Baelor Targaryen','Breakspear',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',170,209,'Valyrian','Prince of Dragonstone and Hand to Daeron II; a beloved heir killed by mischance at the Tourney of Ashford.'),
 ('aerys-i-targaryen','Aerys I Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'male','dead',172,221,'Valyrian','Bookish, childless king who left rule to his Hand, Bloodraven, through drought and the Great Spring Sickness.'),
 ('maekar-i-targaryen','Maekar I Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'male','dead',177,233,'Valyrian','Stern warrior king, fourth son of Daeron II; died storming a rebel castle.'),

 -- Maekar's children
 ('aerion-brightflame','Aerion Targaryen','Brightflame',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',183,232,'Valyrian','Cruel prince who believed he could become a dragon; died drinking wildfire.'),
 ('aemon-maester','Aemon Targaryen','Maester Aemon',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',198,300,'Valyrian','Renounced his claim for a maester''s chain and the Night''s Watch, where he served near a century.'),
 ('aegon-v-targaryen','Aegon V Targaryen','the Unlikely',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',200,259,'Valyrian','A fourth-born son turned reformer king; perished in the fire of Summerhall seeking to wake dragons.'),
 ('betha-blackwood','Betha','Black Betha',NULL,'female','dead',203,264,'Andal','Blackwood wife of Aegon V; a spirited queen and grandmother to the last Targaryen kings.'),
 ('duncan-targaryen','Duncan Targaryen','the Small',(SELECT id FROM house WHERE slug='targaryen'),'male','dead',220,259,'Valyrian','Prince who renounced his crown for love of Jenny of Oldstones; died at Summerhall.'),

 -- Jaehaerys II line
 ('jaehaerys-ii-targaryen','Jaehaerys II Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'male','dead',223,262,'Valyrian','Frail but shrewd king who ended the last Blackfyre threat at the War of the Ninepenny Kings.'),
 ('shaera-targaryen','Shaera Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'female','dead',225,262,'Valyrian','Sister-wife of Jaehaerys II; mother of Aerys II and Rhaella.'),
 ('rhaelle-targaryen','Rhaelle Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'female','dead',221,257,'Valyrian','Daughter of Aegon V wed to Ormund Baratheon; grandmother of Robert, Stannis, and Renly.'),

 -- Rhaegar's children
 ('rhaenys-targaryen-younger','Rhaenys Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'female','dead',280,283,'Valyrian','Young daughter of Rhaegar and Elia; slain in the Sack of King''s Landing.'),
 ('aegon-targaryen-son','Aegon Targaryen',NULL,(SELECT id FROM house WHERE slug='targaryen'),'male','dead',281,283,'Valyrian','Infant son of Rhaegar and Elia, heir to the Iron Throne; killed in the Sack of King''s Landing.'),
 ('elia-martell','Elia','Nymeros Martell',(SELECT id FROM house WHERE slug='martell'),'female','dead',257,283,'Dornish','Dornish princess wed to Rhaegar; murdered with her children in the Sack of King''s Landing.')
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name,
  epithet=COALESCE(excluded.epithet, member.epithet),
  house_id=COALESCE(excluded.house_id, member.house_id),
  gender=excluded.gender,
  status=excluded.status,
  born_year=COALESCE(excluded.born_year, member.born_year),
  died_year=COALESCE(excluded.died_year, member.died_year),
  culture=COALESCE(excluded.culture, member.culture),
  notable_for=COALESCE(excluded.notable_for, member.notable_for),
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));
