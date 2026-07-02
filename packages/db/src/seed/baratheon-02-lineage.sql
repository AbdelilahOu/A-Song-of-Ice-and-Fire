-- Baratheon lineage links.

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='argilac-durrandon') WHERE slug='argella-durrandon';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='orys-baratheon'), mother_id=(SELECT id FROM member WHERE slug='argella-durrandon') WHERE slug IN ('davos-baratheon','raymont-baratheon');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='orys-baratheon'), mother_id=(SELECT id FROM member WHERE slug='argella-durrandon') WHERE slug='rogar-baratheon';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='rogar-baratheon'), mother_id=(SELECT id FROM member WHERE slug='alyssa-velaryon') WHERE slug='boremund-baratheon';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='boremund-baratheon') WHERE slug='borros-baratheon';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='borros-baratheon') WHERE slug IN ('eloris-baratheon','cassandra-baratheon','maris-baratheon','floris-baratheon');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='ormund-baratheon'), mother_id=(SELECT id FROM member WHERE slug='rhaelle-targaryen') WHERE slug='steffon-baratheon';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='steffon-baratheon'), mother_id=(SELECT id FROM member WHERE slug='cassana-estermont') WHERE slug IN ('robert-baratheon','stannis-baratheon','renly-baratheon');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='stannis-baratheon'), mother_id=(SELECT id FROM member WHERE slug='selyse-florent') WHERE slug='shireen-baratheon';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='robert-baratheon') WHERE slug IN ('mya-stone','gendry','barra');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='robert-baratheon'), mother_id=(SELECT id FROM member WHERE slug='delena-florent') WHERE slug='edric-storm';
UPDATE member SET is_bastard=true WHERE slug IN ('mya-stone','gendry','edric-storm','barra');
