-- Enrich already-seeded dragons with epithets and a short "notable for" line.
-- Runs after targaryen-05-dragons.sql (alphabetical order). Idempotent: a plain
-- UPDATE keyed by slug, safe to re-run.

WITH e(slug, epithet, notable_for) AS (
  VALUES
   ('balerion','The Black Dread','The last dragon born in Valyria and mount of Aegon the Conqueror; the greatest dragon Westeros ever knew.'),
   ('vhagar',NULL,'Mount of Queen Visenya and later the oldest, largest living dragon of the Dance of the Dragons.'),
   ('meraxes',NULL,'Queen Rhaenys the Conqueror''s dragon, felled by a scorpion bolt over Dorne.'),
   ('caraxes','The Blood Wyrm','Daemon Targaryen''s lean red dragon, famed for its ferocity and battle-cunning.'),
   ('syrax',NULL,'Queen Rhaenyra''s golden dragon, kept close to the Red Keep through the Dance.'),
   ('sunfyre','The Golden','The most beautiful dragon ever seen, mount of King Aegon II.'),
   ('dreamfyre',NULL,'A pale-blue she-dragon ridden by two Targaryen queens across a century.'),
   ('vermithor','The Bronze Fury','The Old King Jaehaerys''s mount, second only to Vhagar in size during the Dance.'),
   ('silverwing',NULL,'Good Queen Alysanne''s gentle dragon, a survivor of the Dance.'),
   ('meleys','The Red Queen','Princess Rhaenys''s swift crimson dragon, proud and fierce to the last.'),
   ('seasmoke',NULL,'A pale-grey dragon that carried two riders and turned the tide at sea.'),
   ('vermax',NULL,'Prince Jacaerys Velaryon''s dragon, lost in the great sea battle of the Gullet.'),
   ('arrax',NULL,'Lucerys Velaryon''s young dragon, whose death sparked the Dance of the Dragons.'),
   ('tyraxes',NULL,'Prince Joffrey Velaryon''s dragon, slain in its pit beneath the Dragonpit.'),
   ('tessarion','The Blue Queen','Daeron the Daring''s cobalt-and-copper dragon, one of the fairest of its kind.'),
   ('moondancer',NULL,'Baela Targaryen''s small, agile dragon that grounded Sunfyre at the Gullet.'),
   ('morning',NULL,'A pink-and-black hatchling born at the war''s end, among the last of the dragons.'),
   ('stormcloud',NULL,'Bore the boy-king Aegon III to safety at the cost of its own life.'),
   ('drogon',NULL,'The largest and fiercest of Daenerys Targaryen''s three dragons, black as night.'),
   ('rhaegal',NULL,'The green dragon of Daenerys, named for her lost brother Rhaegar.'),
   ('viserion',NULL,'The cream-and-gold dragon of Daenerys, named for her brother Viserys.')
)
UPDATE dragon
SET epithet = COALESCE((SELECT e.epithet FROM e WHERE e.slug = dragon.slug), dragon.epithet),
    notable_for = COALESCE((SELECT e.notable_for FROM e WHERE e.slug = dragon.slug), dragon.notable_for),
    updated_at = (cast(unixepoch('subsecond') * 1000 as integer))
WHERE dragon.slug IN (SELECT slug FROM e);
