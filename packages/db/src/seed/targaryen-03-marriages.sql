-- Targaryen marriages. Idempotent: inserts a pair only if no marriage already
-- links those two members (in either order).
WITH pairs(a_slug, b_slug, status, sy, ey, secret) AS (
  VALUES
   ('aegon-i-targaryen','visenya-targaryen','widowed',-11,37,0),
   ('aegon-i-targaryen','rhaenys-targaryen','widowed',-11,10,0),
   ('aenys-i-targaryen','alyssa-velaryon','widowed',22,42,0),
   ('rhaena-targaryen','aegon-uncrowned-targaryen','widowed',41,43,0),
   ('jaehaerys-i-targaryen','alysanne-targaryen','widowed',49,100,0),
   ('aemon-targaryen-prince','jocelyn-baratheon','widowed',60,92,0),
   ('baelon-targaryen','alyssa-targaryen','widowed',72,84,0),
   ('viserys-i-targaryen','aemma-arryn','widowed',93,105,0),
   ('viserys-i-targaryen','alicent-hightower','widowed',106,129,0),
   ('daemon-targaryen','laena-velaryon','widowed',115,120,0),
   ('rhaenyra-targaryen','laenor-velaryon','widowed',114,120,0),
   ('daemon-targaryen','rhaenyra-targaryen','married',120,130,0),
   ('corlys-velaryon','rhaenys-queen-who-never-was','widowed',90,129,0),
   ('aegon-ii-targaryen','helaena-targaryen','widowed',123,130,0),
   ('aegon-iii-targaryen','jaehaera-targaryen','widowed',131,133,0),
   ('aegon-iii-targaryen','daenaera-velaryon','widowed',133,157,0),
   ('aegon-iv-targaryen','naerys-targaryen','widowed',153,179,0),
   ('daeron-ii-targaryen','myriah-martell','widowed',168,209,0),
   ('aegon-v-targaryen','betha-blackwood','widowed',220,259,0),
   ('jaehaerys-ii-targaryen','shaera-targaryen','widowed',240,262,0),
   ('aerys-ii-targaryen','rhaella-targaryen','widowed',258,283,0),
   ('rhaegar-targaryen','elia-martell','widowed',280,283,0)
)
INSERT INTO marriage (spouse_a_id, spouse_b_id, status, start_year, end_year, is_secret)
SELECT a.id, b.id, p.status, p.sy, p.ey, p.secret
FROM pairs p JOIN member a ON a.slug=p.a_slug JOIN member b ON b.slug=p.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM marriage m
  WHERE (m.spouse_a_id=a.id AND m.spouse_b_id=b.id)
     OR (m.spouse_a_id=b.id AND m.spouse_b_id=a.id)
);
