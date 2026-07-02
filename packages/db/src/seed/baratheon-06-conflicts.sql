-- Baratheon conflicts and events.

WITH loc(slug, name, type, region, house_slug, descr) AS (
  VALUES
   ('storms-end','Storm''s End','castle','The Stormlands','baratheon','Ancient Durrandon fortress and seat of House Baratheon.'),
   ('shipbreaker-bay','Shipbreaker Bay','landmark','The Stormlands',NULL,'Storm-torn waters below Storm''s End.'),
   ('ashford-meadow','Ashford Meadow','landmark','The Reach',NULL,'Tourney ground where Prince Duncan broke his betrothal to Lyonel Baratheon''s daughter.'),
   ('storms-end-parley','Parley Beneath Storm''s End','other','The Stormlands','baratheon','Site of Renly Baratheon''s murder by a shadow.')
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
   ('aegons-conquest','Aegon''s Conquest',-2,1,'targaryen','Six kingdoms bent the knee','Orys Baratheon defeated the last Storm King and founded House Baratheon.'),
   ('laughing-storm-rebellion','The Laughing Storm Rebellion',239,239,'targaryen','Reconciliation by trial of seven','Lyonel Baratheon rebelled after Prince Duncan broke his betrothal to his daughter.'),
   ('war-of-ninepenny-kings','The War of the Ninepenny Kings',259,260,'targaryen','Band of Nine defeated','Ormund Baratheon died leading the royal host in the Stepstones.'),
   ('roberts-rebellion','Robert''s Rebellion',282,283,'baratheon','Rebel victory','Robert Baratheon overthrew Aerys II and took the Iron Throne.'),
   ('war-of-the-five-kings','The War of the Five Kings',298,300,NULL,'Lannister-Tyrell regime holds King''s Landing','Baratheon brothers and heirs were central claimants in the civil war.')
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
   ('last-storm','The Last Storm','aegons-conquest',-2,'storms-end','Targaryen-Baratheon','Argilac slain','Orys Baratheon slew Argilac Durrandon and took Storm''s End.'),
   ('battle-of-summerhall','The Battle of Summerhall','roberts-rebellion',283,'summerhall','Rebels','Rebel victory','Robert defeated loyalist forces after returning from the south.'),
   ('battle-of-ashford','The Battle of Ashford','roberts-rebellion',283,'ashford-meadow','Loyalists','Loyalist victory','Randyll Tarly checked Robert Baratheon in the Reach.'),
   ('siege-of-storms-end','The Siege of Storm''s End','roberts-rebellion',282,'storms-end','Rebels','Storm''s End held','Stannis held Storm''s End through a long Tyrell-Redwyne siege.'),
   ('battle-of-the-trident','The Battle of the Trident','roberts-rebellion',283,'the-trident','Rebels','Rebel victory','Robert slew Rhaegar Targaryen in single combat.'),
   ('battle-of-the-blackwater','The Battle of the Blackwater','war-of-the-five-kings',299,'blackwater-bay','Lannister-Tyrell','Stannis defeated','Stannis Baratheon''s assault on King''s Landing failed.')
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
   ('founding-of-house-baratheon','Founding of House Baratheon','founding',1,'storms-end','aegons-conquest','last-storm','Orys Baratheon married Argella Durrandon and took the storm kings'' seat and words.'),
   ('steffon-and-cassana-drown','Steffon and Cassana Drown','death',278,'shipbreaker-bay',NULL,NULL,'Robert and Stannis watched their parents drown within sight of Storm''s End.'),
   ('robert-crowned','Robert Baratheon Crowned','coronation',283,'kings-landing','roberts-rebellion',NULL,'Robert took the Iron Throne after the Sack of King''s Landing.'),
   ('robert-dies','Robert Baratheon Dies','death',298,'kings-landing',NULL,NULL,'Robert died from wounds taken during a boar hunt.'),
   ('renly-murdered','Renly Baratheon Murdered','death',299,'storms-end-parley','war-of-the-five-kings',NULL,'Renly was killed by a shadow before battle with Stannis.')
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
