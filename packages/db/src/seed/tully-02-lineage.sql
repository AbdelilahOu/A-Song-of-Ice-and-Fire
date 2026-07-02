-- Tully lineage links.

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='grover-tully') WHERE slug='elmo-tully';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='elmo-tully') WHERE slug IN ('kermit-tully','oscar-tully');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='hoster-tully'), mother_id=(SELECT id FROM member WHERE slug='minisa-whent') WHERE slug IN ('catelyn-tully','lysa-tully','edmure-tully');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='ned-stark'), mother_id=(SELECT id FROM member WHERE slug='catelyn-tully') WHERE slug='robb-stark';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='jon-arryn'), mother_id=(SELECT id FROM member WHERE slug='lysa-tully') WHERE slug='robert-arryn';
