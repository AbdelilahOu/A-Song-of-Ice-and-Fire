-- Tyrell conflicts and events.

WITH loc(slug, name, type, region, house_slug, descr) AS (
  VALUES
   ('highgarden','Highgarden','castle','The Reach','tyrell','Seat of House Tyrell.'),
   ('ashford-meadow','Ashford Meadow','landmark','The Reach',NULL,'Tourney and battlefield near Ashford.'),
   ('bitterbridge','Bitterbridge','town','The Reach',NULL,'Reach town near Renly''s camp.'),
   ('sept-of-baelor','The Great Sept of Baelor','landmark','The Crownlands',NULL,'Great sept in King''s Landing where Margaery was imprisoned and later killed in the show continuity.')
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
   ('aegons-conquest','Aegon''s Conquest',-2,1,'targaryen','Six kingdoms bent the knee','The Gardener kings died on the Field of Fire and the Tyrells were raised.'),
   ('dance-of-the-dragons','The Dance of the Dragons',129,131,'targaryen','Pyrrhic victory for the blacks','House Tyrell stayed largely neutral under a regency.'),
   ('roberts-rebellion','Robert''s Rebellion',282,283,'baratheon','Rebel victory','Mace Tyrell supported the Targaryens and besieged Storm''s End.'),
   ('war-of-the-five-kings','The War of the Five Kings',298,300,NULL,'Lannister-Tyrell regime holds King''s Landing','House Tyrell backed Renly, then joined the Lannisters.')
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
   ('field-of-fire','The Field of Fire','aegons-conquest',-2,NULL,'Targaryen','Gardener-Two Kings host burned','The Gardener king died and Harlen Tyrell was raised to Highgarden.'),
   ('siege-of-storms-end','The Siege of Storm''s End','roberts-rebellion',282,'storms-end','Rebels','Storm''s End held','Mace Tyrell and Paxter Redwyne besieged Stannis Baratheon.'),
   ('battle-of-ashford','The Battle of Ashford','roberts-rebellion',283,'ashford-meadow','Loyalists','Loyalist victory','Randyll Tarly defeated Robert Baratheon.'),
   ('battle-of-the-blackwater','The Battle of the Blackwater','war-of-the-five-kings',299,'blackwater-bay','Lannister-Tyrell','King''s Landing held','Tyrell reinforcements broke Stannis Baratheon''s attack.')
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
   ('tyrells-raised-to-highgarden','Tyrells Raised to Highgarden','alliance',1,'highgarden','aegons-conquest',NULL,'Aegon I granted Highgarden and the Reach to Harlen Tyrell.'),
   ('renly-marries-margaery','Renly Marries Margaery','marriage',299,'bitterbridge','war-of-the-five-kings',NULL,'The Tyrells backed Renly through his marriage to Margaery.'),
   ('tyrell-lannister-alliance','Tyrell-Lannister Alliance','alliance',299,'kings-landing','war-of-the-five-kings','battle-of-the-blackwater','The Tyrell host saved King''s Landing and joined the royal regime.'),
   ('joffreys-wedding-poisoning','Joffrey Baratheon Poisoned','death',300,'purple-wedding','war-of-the-five-kings',NULL,'Joffrey died at his wedding to Margaery.')
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
