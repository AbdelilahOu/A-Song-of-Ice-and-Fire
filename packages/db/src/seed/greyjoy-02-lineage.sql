-- Greyjoy lineage links.

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='quellon-greyjoy') WHERE slug IN ('balon-greyjoy','euron-greyjoy','victarion-greyjoy','urrigon-greyjoy','aeron-greyjoy','robin-greyjoy','quenton-greyjoy');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='balon-greyjoy'), mother_id=(SELECT id FROM member WHERE slug='alannys-harlaw') WHERE slug IN ('rodrik-greyjoy','maron-greyjoy','asha-greyjoy','theon-greyjoy');
