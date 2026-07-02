-- Martell lineage links.

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='mors-martell'), mother_id=(SELECT id FROM member WHERE slug='nymeria') WHERE slug IN ('morgan-martell','myria-martell-nymerias-daughter');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='nymor-martell') WHERE slug='deria-martell';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='daeron-ii-targaryen'), mother_id=(SELECT id FROM member WHERE slug='myriah-martell') WHERE slug='daenerys-targaryen-princess';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='doran-martell'), mother_id=(SELECT id FROM member WHERE slug='mellario-of-norvos') WHERE slug IN ('arianne-martell','quentyn-martell','trystane-martell');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='rhaegar-targaryen'), mother_id=(SELECT id FROM member WHERE slug='elia-martell') WHERE slug IN ('rhaenys-targaryen-younger','aegon-targaryen-son');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='oberyn-martell') WHERE slug IN ('obara-sand','nymeria-sand','tyene-sand','sarella-sand');
UPDATE member SET is_bastard=true WHERE slug IN ('ellaria-sand','obara-sand','nymeria-sand','tyene-sand','sarella-sand');
