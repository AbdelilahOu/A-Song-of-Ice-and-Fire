-- Martell marriages.

WITH pairs(a_slug, b_slug, status, sy, ey, secret, notes) AS (
  VALUES
   ('nymeria','mors-martell','widowed',NULL,NULL,0,'Union that founded unified Martell rule in Dorne.'),
   ('daeron-ii-targaryen','myriah-martell','widowed',168,209,0,'Marriage pact that helped bring Dorne into the realm.'),
   ('maron-martell','daenerys-targaryen-princess','widowed',187,NULL,0,'Marriage sealing Dorne''s peaceful union with the Iron Throne.'),
   ('doran-martell','mellario-of-norvos','separated',NULL,NULL,0,'Mellario returned to Norvos after the marriage soured.'),
   ('rhaegar-targaryen','elia-martell','widowed',280,283,0,NULL),
   ('trystane-martell','myrcella-baratheon','betrothed',299,NULL,0,'Betrothal used to bring Dorne into Tyrion''s anti-Stannis alliance.')
)
INSERT INTO marriage (spouse_a_id, spouse_b_id, status, start_year, end_year, is_secret, notes)
SELECT a.id, b.id, p.status, p.sy, p.ey, p.secret, p.notes
FROM pairs p JOIN member a ON a.slug=p.a_slug JOIN member b ON b.slug=p.b_slug
WHERE NOT EXISTS (
  SELECT 1 FROM marriage m
  WHERE (m.spouse_a_id=a.id AND m.spouse_b_id=b.id)
     OR (m.spouse_a_id=b.id AND m.spouse_b_id=a.id)
);
