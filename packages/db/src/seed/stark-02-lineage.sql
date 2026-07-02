-- Stark lineage links.

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='torrhen-stark') WHERE slug='brandon-snow';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='rickon-stark-father-of-cregan') WHERE slug='cregan-stark';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='cregan-stark'), mother_id=(SELECT id FROM member WHERE slug='arra-norrey') WHERE slug='rickon-stark-son-of-cregan';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='cregan-stark'), mother_id=(SELECT id FROM member WHERE slug='alysanne-blackwood') WHERE slug IN ('jonnel-stark','barthogan-stark','brandon-stark-son-of-cregan');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='beron-stark'), mother_id=(SELECT id FROM member WHERE slug='lorna-tyrell') WHERE slug IN ('willam-stark','artos-stark');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='edwyle-stark') WHERE slug='rickard-stark';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='rickard-stark'), mother_id=(SELECT id FROM member WHERE slug='lyarra-stark') WHERE slug IN ('brandon-stark-son-of-rickard','ned-stark','lyanna-stark','benjen-stark');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='ned-stark'), mother_id=(SELECT id FROM member WHERE slug='catelyn-tully') WHERE slug IN ('robb-stark','sansa-stark','arya-stark','bran-stark','rickon-stark-young');
UPDATE member SET mother_id=(SELECT id FROM member WHERE slug='lyanna-stark') WHERE slug='jon-snow';
UPDATE member SET is_bastard=true WHERE slug IN ('brandon-snow','jon-snow');
