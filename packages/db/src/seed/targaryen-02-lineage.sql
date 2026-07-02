-- Targaryen lineage: add one missing member, then wire every father/mother link
-- by slug. Idempotent; safe to re-run. Unknown parents are left NULL.

INSERT INTO member (slug, name, house_id, gender, status, born_year, died_year, culture, notable_for)
VALUES
 ('alyssa-targaryen','Alyssa Targaryen',(SELECT id FROM house WHERE slug='targaryen'),'female','dead',55,84,'Valyrian','Daughter of Jaehaerys I and sister-wife of Baelon the Brave; mother of King Viserys I and Prince Daemon.')
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name, house_id=excluded.house_id, gender=excluded.gender, status=excluded.status,
  born_year=excluded.born_year, died_year=excluded.died_year, culture=excluded.culture,
  notable_for=excluded.notable_for, updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

-- Parent-link helper is inlined per child below.
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aerion-targaryen'), mother_id=(SELECT id FROM member WHERE slug='valaena-velaryon') WHERE slug IN ('aegon-i-targaryen','visenya-targaryen','rhaenys-targaryen');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aegon-i-targaryen'), mother_id=(SELECT id FROM member WHERE slug='visenya-targaryen') WHERE slug='maegor-i-targaryen';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aegon-i-targaryen'), mother_id=(SELECT id FROM member WHERE slug='rhaenys-targaryen') WHERE slug='aenys-i-targaryen';

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aenys-i-targaryen'), mother_id=(SELECT id FROM member WHERE slug='alyssa-velaryon') WHERE slug IN ('jaehaerys-i-targaryen','alysanne-targaryen','rhaena-targaryen','aegon-uncrowned-targaryen');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='jaehaerys-i-targaryen'), mother_id=(SELECT id FROM member WHERE slug='alysanne-targaryen') WHERE slug IN ('aemon-targaryen-prince','baelon-targaryen','daella-targaryen','alyssa-targaryen');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aemon-targaryen-prince'), mother_id=(SELECT id FROM member WHERE slug='jocelyn-baratheon') WHERE slug='rhaenys-queen-who-never-was';
UPDATE member SET mother_id=(SELECT id FROM member WHERE slug='daella-targaryen') WHERE slug='aemma-arryn';

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='baelon-targaryen'), mother_id=(SELECT id FROM member WHERE slug='alyssa-targaryen') WHERE slug IN ('viserys-i-targaryen','daemon-targaryen');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='corlys-velaryon'), mother_id=(SELECT id FROM member WHERE slug='rhaenys-queen-who-never-was') WHERE slug IN ('laenor-velaryon','laena-velaryon');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='viserys-i-targaryen'), mother_id=(SELECT id FROM member WHERE slug='aemma-arryn') WHERE slug='rhaenyra-targaryen';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='viserys-i-targaryen'), mother_id=(SELECT id FROM member WHERE slug='alicent-hightower') WHERE slug IN ('aegon-ii-targaryen','helaena-targaryen','aemond-targaryen','daeron-targaryen-daring');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='laenor-velaryon'), mother_id=(SELECT id FROM member WHERE slug='rhaenyra-targaryen') WHERE slug IN ('jacaerys-velaryon','lucerys-velaryon','joffrey-velaryon');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='daemon-targaryen'), mother_id=(SELECT id FROM member WHERE slug='rhaenyra-targaryen') WHERE slug IN ('aegon-iii-targaryen','viserys-ii-targaryen');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='daemon-targaryen'), mother_id=(SELECT id FROM member WHERE slug='laena-velaryon') WHERE slug IN ('baela-targaryen','rhaena-targaryen-morning');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aegon-ii-targaryen'), mother_id=(SELECT id FROM member WHERE slug='helaena-targaryen') WHERE slug IN ('jaehaerys-targaryen-son','jaehaera-targaryen');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aegon-iii-targaryen'), mother_id=(SELECT id FROM member WHERE slug='daenaera-velaryon') WHERE slug IN ('daeron-i-targaryen','baelor-i-targaryen','daena-targaryen');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='viserys-ii-targaryen') WHERE slug IN ('aegon-iv-targaryen','naerys-targaryen','aemon-dragonknight');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aegon-iv-targaryen'), mother_id=(SELECT id FROM member WHERE slug='naerys-targaryen') WHERE slug='daeron-ii-targaryen';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aegon-iv-targaryen'), mother_id=(SELECT id FROM member WHERE slug='daena-targaryen') WHERE slug='daemon-blackfyre';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aegon-iv-targaryen') WHERE slug IN ('aegor-rivers','brynden-rivers');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='daeron-ii-targaryen'), mother_id=(SELECT id FROM member WHERE slug='myriah-martell') WHERE slug IN ('baelor-breakspear','aerys-i-targaryen','maekar-i-targaryen');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='maekar-i-targaryen') WHERE slug IN ('aerion-brightflame','aemon-maester','aegon-v-targaryen');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aegon-v-targaryen'), mother_id=(SELECT id FROM member WHERE slug='betha-blackwood') WHERE slug IN ('duncan-targaryen','jaehaerys-ii-targaryen','shaera-targaryen','rhaelle-targaryen');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='jaehaerys-ii-targaryen'), mother_id=(SELECT id FROM member WHERE slug='shaera-targaryen') WHERE slug IN ('aerys-ii-targaryen','rhaella-targaryen');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='aerys-ii-targaryen'), mother_id=(SELECT id FROM member WHERE slug='rhaella-targaryen') WHERE slug IN ('rhaegar-targaryen','viserys-targaryen','daenerys-targaryen');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='rhaegar-targaryen'), mother_id=(SELECT id FROM member WHERE slug='elia-martell') WHERE slug IN ('rhaenys-targaryen-younger','aegon-targaryen-son');

-- Bastardy flags
UPDATE member SET is_bastard=true, is_legitimized=true WHERE slug='daemon-blackfyre';
UPDATE member SET is_bastard=true WHERE slug IN ('aegor-rivers','brynden-rivers');
