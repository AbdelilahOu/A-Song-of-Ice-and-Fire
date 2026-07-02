-- Stark conflicts and events.

WITH loc(slug, name, type, region, house_slug, descr) AS (
  VALUES
   ('winterfell','Winterfell','castle','The North','stark','Ancient seat of House Stark.'),
   ('the-wall','The Wall','landmark','The North',NULL,'Massive northern ice wall associated with Bran the Builder.'),
   ('tower-of-joy','The Tower of Joy','tower','Dorne',NULL,'Dornish tower where Lyanna Stark died.'),
   ('wolfswood','The Wolfswood','region','The North','stark','Forest near Winterfell.'),
   ('the-neck','The Neck','region','The North',NULL,'Southern marshy gateway to the North.')
)
INSERT INTO location (slug, name, type, region, controlling_house_id, description)
SELECT loc.slug, loc.name, loc.type, loc.region, (SELECT id FROM house WHERE slug=loc.house_slug), loc.descr
FROM loc
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name,
  type=excluded.type,
  region=COALESCE(excluded.region, location.region),
  controlling_house_id=COALESCE(excluded.controlling_house_id, location.controlling_house_id),
  description=COALESCE(excluded.description, location.description),
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

WITH w(slug, name, sy, ey, victor_slug, outcome, description) AS (
  VALUES
   ('aegons-conquest','Aegon''s Conquest',-2,1,'targaryen','Six kingdoms bent the knee','Torrhen Stark knelt rather than burn.'),
   ('dance-of-the-dragons','The Dance of the Dragons',129,131,'targaryen','Pyrrhic victory for the blacks','Cregan Stark marched south at war''s end.'),
   ('roberts-rebellion','Robert''s Rebellion',282,283,'baratheon','Rebel victory','Rickard and Brandon Stark''s deaths helped ignite the rebellion.'),
   ('greyjoy-rebellion','The Greyjoy Rebellion',289,289,'baratheon','Royal victory','Eddard Stark helped storm Pyke and took Theon as ward.'),
   ('war-of-the-five-kings','The War of the Five Kings',298,300,NULL,'Lannister-Tyrell regime holds King''s Landing','Robb Stark was crowned King in the North and Trident.')
)
INSERT INTO war (slug, name, start_year, end_year, victor_house_id, outcome, description)
SELECT w.slug, w.name, w.sy, w.ey, (SELECT id FROM house WHERE slug=w.victor_slug), w.outcome, w.description
FROM w
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name,
  start_year=excluded.start_year,
  end_year=excluded.end_year,
  victor_house_id=COALESCE(excluded.victor_house_id, war.victor_house_id),
  outcome=excluded.outcome,
  description=excluded.description,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

WITH b(slug, name, war_slug, year, loc_slug, victor, outcome, description) AS (
  VALUES
   ('torrhen-kneels','Torrhen Stark Kneels','aegons-conquest',1,'the-trident','Targaryen','North submits','Torrhen Stark avoided battle and bent the knee.'),
   ('hour-of-the-wolf','The Hour of the Wolf','dance-of-the-dragons',131,'kings-landing','Blacks','Regency stabilized','Cregan Stark judged the remaining conspirators after Aegon II''s death.'),
   ('tower-of-joy','The Tower of Joy','roberts-rebellion',283,'tower-of-joy','Stark','Lyanna found dying','Eddard Stark found Lyanna and the newborn Jon.'),
   ('siege-of-pyke','The Siege of Pyke','greyjoy-rebellion',289,'pyke','Royal forces','Balon defeated','Eddard Stark helped take Pyke.'),
   ('battle-of-the-whispering-wood','The Battle of the Whispering Wood','war-of-the-five-kings',299,'wolfswood','Northmen','Jaime captured','Robb Stark captured Jaime Lannister.'),
   ('battle-of-the-camps','The Battle of the Camps','war-of-the-five-kings',299,'tumblestone','Northmen-Riverlords','Riverrun relieved','Robb Stark relieved Riverrun.'),
   ('red-wedding','The Red Wedding','war-of-the-five-kings',299,'the-twins','Lannister-Frey-Bolton','Northern cause broken','Robb and Catelyn were murdered under guest right.'),
   ('capture-of-winterfell','The Capture of Winterfell','war-of-the-five-kings',299,'winterfell','Ironborn','Winterfell taken','Theon Greyjoy seized Winterfell.')
)
INSERT INTO battle (slug, name, war_id, year, location_id, victor_side, outcome, description)
SELECT b.slug, b.name, (SELECT id FROM war WHERE slug=b.war_slug), b.year,
       (SELECT id FROM location WHERE slug=b.loc_slug), b.victor, b.outcome, b.description
FROM b
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name,
  war_id=COALESCE(excluded.war_id, battle.war_id),
  year=excluded.year,
  location_id=COALESCE(excluded.location_id, battle.location_id),
  victor_side=excluded.victor_side,
  outcome=excluded.outcome,
  description=excluded.description,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

WITH e(slug, name, type, year, loc_slug, war_slug, battle_slug, description) AS (
  VALUES
   ('founding-of-winterfell','Founding of Winterfell','founding',NULL,'winterfell',NULL,NULL,'Brandon the Builder founded Winterfell in legend.'),
   ('torrhen-stark-kneels','Torrhen Stark Kneels','alliance',1,'the-trident','aegons-conquest','torrhen-kneels','The North submitted to Aegon I.'),
   ('rickard-and-brandon-executed','Rickard and Brandon Stark Executed','death',282,'kings-landing','roberts-rebellion',NULL,'Aerys II murdered Rickard and Brandon Stark.'),
   ('lyanna-dies','Lyanna Stark Dies','death',283,'tower-of-joy','roberts-rebellion','tower-of-joy','Lyanna died in Eddard''s arms after childbirth.'),
   ('robb-crowned','Robb Stark Crowned','coronation',299,'riverrun','war-of-the-five-kings',NULL,'Northern and riverlords acclaimed Robb as king.'),
   ('red-wedding-event','The Red Wedding','betrayal',299,'the-twins','war-of-the-five-kings','red-wedding','Robb and Catelyn Stark were murdered.')
)
INSERT INTO event (slug, name, type, year, location_id, war_id, battle_id, description)
SELECT e.slug, e.name, e.type, e.year,
       (SELECT id FROM location WHERE slug=e.loc_slug),
       (SELECT id FROM war WHERE slug=e.war_slug),
       (SELECT id FROM battle WHERE slug=e.battle_slug),
       e.description
FROM e
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name,
  type=excluded.type,
  year=COALESCE(excluded.year, event.year),
  location_id=COALESCE(excluded.location_id, event.location_id),
  war_id=COALESCE(excluded.war_id, event.war_id),
  battle_id=COALESCE(excluded.battle_id, event.battle_id),
  description=excluded.description,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));
