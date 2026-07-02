-- Lannister lineage links by slug. Idempotent and order-independent.

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='tyrion-iii-lannister') WHERE slug='gerold-ii-lannister';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='gerold-iii-lannister'), mother_id=NULL WHERE slug='lannister-daughter-of-gerold-iii';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='joffrey-lydden'), mother_id=(SELECT id FROM member WHERE slug='lannister-daughter-of-gerold-iii') WHERE slug='cerion-lannister';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='lancel-i-lannister') WHERE slug='loreon-iii-lannister';

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='loren-i-lannister') WHERE slug='lyman-lannister';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='lyman-lannister'), mother_id=(SELECT id FROM member WHERE slug='jocasta-tarbeck') WHERE slug='tyler-hill';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='jason-lannister-dance'), mother_id=(SELECT id FROM member WHERE slug='johanna-westerling') WHERE slug IN ('loreon-lannister-son-of-jason','cerelle-lannister-daughter-of-jason','tyshara-lannister');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='damon-lannister-grey-lion'), mother_id=(SELECT id FROM member WHERE slug='cerissa-brax') WHERE slug IN ('tybolt-lannister-son-of-damon','gerold-lannister-golden');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='tybolt-lannister-son-of-damon'), mother_id=(SELECT id FROM member WHERE slug='teora-kyndall') WHERE slug='cerelle-lannister-lady-of-casterly-rock';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='gerold-lannister-golden'), mother_id=(SELECT id FROM member WHERE slug='rohanne-webber') WHERE slug IN ('tywald-lannister','tion-lannister-son-of-gerold','tytos-lannister','jason-lannister-son-of-gerold');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='jason-lannister-son-of-gerold'), mother_id=(SELECT id FROM member WHERE slug='marla-prester') WHERE slug IN ('joanna-lannister','stafford-lannister');

UPDATE member SET father_id=(SELECT id FROM member WHERE slug='tytos-lannister'), mother_id=(SELECT id FROM member WHERE slug='jeyne-marbrand') WHERE slug IN ('tywin-lannister','kevan-lannister','genna-lannister','tygett-lannister','gerion-lannister');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='tywin-lannister'), mother_id=(SELECT id FROM member WHERE slug='joanna-lannister') WHERE slug IN ('cersei-lannister','jaime-lannister','tyrion-lannister');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='kevan-lannister'), mother_id=(SELECT id FROM member WHERE slug='dorna-swyft') WHERE slug IN ('lancel-lannister','willem-lannister','martyn-lannister','janei-lannister');
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='tygett-lannister'), mother_id=(SELECT id FROM member WHERE slug='darlessa-marbrand') WHERE slug='tyrek-lannister';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='gerion-lannister') WHERE slug='joy-hill';
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='stafford-lannister') WHERE slug IN ('daven-lannister','cerenna-lannister','myrielle-lannister');

-- The Baratheon royal children are publicly Robert's issue, but biologically Jaime's.
UPDATE member SET father_id=(SELECT id FROM member WHERE slug='jaime-lannister'), mother_id=(SELECT id FROM member WHERE slug='cersei-lannister') WHERE slug IN ('joffrey-baratheon','myrcella-baratheon','tommen-baratheon');

UPDATE member SET is_bastard=true WHERE slug IN ('tyler-hill','joy-hill');
