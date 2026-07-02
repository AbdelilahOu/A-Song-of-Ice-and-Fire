-- Tyrell lineage links.

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='leo-tyrell-longthorn') WHERE slug='lorna-tyrell';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='luthor-tyrell'), mother_id=(SELECT id FROM member WHERE slug='olenna-redwyne') WHERE slug='mace-tyrell';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='mace-tyrell'), mother_id=(SELECT id FROM member WHERE slug='alerie-hightower') WHERE slug IN ('willas-tyrell','garlan-tyrell','loras-tyrell','margaery-tyrell');
