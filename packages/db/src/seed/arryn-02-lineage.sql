-- Arryn lineage links.

UPDATE member SET mother_id=(SELECT id FROM member WHERE slug='sharra-arryn') WHERE slug='ronnel-arryn';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='arnold-arryn') WHERE slug='jeyne-arryn';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='jesper-arryn') WHERE slug IN ('jon-arryn','rowena-arryn','alys-arryn');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='jon-arryn'), mother_id=(SELECT id FROM member WHERE slug='lysa-tully') WHERE slug='robert-arryn';
UPDATE member SET mother_id=(SELECT id FROM member WHERE slug='alys-arryn') WHERE slug='harrold-hardyng';
