-- Tully conflicts and events.

WITH loc(slug, name, type, region, house_slug, descr) AS (
  VALUES
   ('riverrun','Riverrun','castle','The Riverlands','tully','Seat of House Tully at the joining of the Red Fork and Tumblestone.'),
   ('harrenhal','Harrenhal','castle','The Riverlands',NULL,'Vast cursed castle in the riverlands.'),
   ('the-twins','The Twins','castle','The Riverlands',NULL,'Seat of House Frey and site of the Red Wedding.'),
   ('tumblestone','The Tumblestone','landmark','The Riverlands',NULL,'River below Riverrun used in the Battle of the Camps.')
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
   ('aegons-conquest','Aegon''s Conquest',-2,1,'targaryen','Six kingdoms bent the knee','Edmure Tully led riverlords against Harren Hoare and was rewarded with paramountcy.'),
   ('dance-of-the-dragons','The Dance of the Dragons',129,131,'targaryen','Pyrrhic victory for the blacks','House Tully eventually joined Rhaenyra''s blacks.'),
   ('roberts-rebellion','Robert''s Rebellion',282,283,'baratheon','Rebel victory','Hoster Tully joined the rebellion through Stark and Arryn marriages.'),
   ('war-of-the-five-kings','The War of the Five Kings',298,300,NULL,'Lannister-Tyrell regime holds King''s Landing','House Tully supported Robb Stark as King in the North and Trident.')
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
   ('burning-of-harrenhal','The Burning of Harrenhal','aegons-conquest',-2,'harrenhal','Targaryen','Hoare rule ended','Aegon burned Harrenhal and broke ironborn rule over the riverlands.'),
   ('battle-of-the-kingsroad','The Battle of the Kingsroad','dance-of-the-dragons',131,NULL,'Blacks','Green host defeated','Kermit Tully led the riverlords against Borros Baratheon.'),
   ('battle-of-the-bells','The Battle of the Bells','roberts-rebellion',283,NULL,'Rebels','Rebel victory','Rebels saved Robert Baratheon from loyalist forces at Stoney Sept.'),
   ('battle-of-the-camps','The Battle of the Camps','war-of-the-five-kings',299,'tumblestone','Northmen-Riverlords','Riverrun relieved','Robb Stark destroyed Jaime Lannister''s besieging camps.'),
   ('red-wedding','The Red Wedding','war-of-the-five-kings',299,'the-twins','Lannister-Frey-Bolton','Northern cause broken','Robb Stark and Catelyn were murdered during Edmure''s wedding feast.'),
   ('second-siege-of-riverrun','The Second Siege of Riverrun','war-of-the-five-kings',300,'riverrun','Lannister-Frey','Riverrun surrendered','Jaime Lannister forced Edmure to yield Riverrun.')
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
   ('tully-paramountcy','House Tully Raised to Paramountcy','alliance',1,'riverrun','aegons-conquest',NULL,'Aegon made Edmure Tully Lord Paramount of the Trident.'),
   ('hoster-tully-dies','Hoster Tully Dies','death',299,'riverrun','war-of-the-five-kings',NULL,'Hoster died during the war and Edmure succeeded him.'),
   ('red-wedding-event','The Red Wedding','betrayal',299,'the-twins','war-of-the-five-kings','red-wedding','Walder Frey betrayed Robb Stark under guest right.'),
   ('lysa-falls','Lysa Arryn Falls','death',300,NULL,NULL,NULL,'Petyr Baelish pushed Lysa Arryn through the Moon Door.')
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
  year=excluded.year,
  location_id=COALESCE(excluded.location_id, event.location_id),
  war_id=COALESCE(excluded.war_id, event.war_id),
  battle_id=COALESCE(excluded.battle_id, event.battle_id),
  description=excluded.description,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));
