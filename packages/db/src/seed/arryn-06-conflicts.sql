-- Arryn conflicts and events.

WITH loc(slug, name, type, region, house_slug, descr) AS (
  VALUES
   ('the-eyrie','The Eyrie','castle','The Vale','arryn','Mountain castle and seat of House Arryn.'),
   ('gulltown','Gulltown','city','The Vale',NULL,'Major port of the Vale.'),
   ('bloody-gate','The Bloody Gate','stronghold','The Vale','arryn','Gate controlling the mountain road into the Vale.'),
   ('moon-door','The Moon Door','landmark','The Vale','arryn','Execution door in the Eyrie''s High Hall.')
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
   ('andal-conquest-of-the-vale','The Andal Conquest of the Vale',NULL,NULL,'arryn','Andal victory','Artys Arryn defeated Robar II Royce and founded Andal rule in the Vale.'),
   ('aegons-conquest','Aegon''s Conquest',-2,1,'targaryen','Six kingdoms bent the knee','The Vale submitted peacefully after Visenya landed at the Eyrie.'),
   ('dance-of-the-dragons','The Dance of the Dragons',129,131,'targaryen','Pyrrhic victory for the blacks','Jeyne Arryn supported Rhaenyra in return for dragon protection.'),
   ('roberts-rebellion','Robert''s Rebellion',282,283,'baratheon','Rebel victory','Jon Arryn began the rebellion by refusing to surrender Robert and Eddard.')
)
INSERT INTO war (slug, name, start_year, end_year, victor_house_id, outcome, description)
SELECT w.slug, w.name, w.sy, w.ey, (SELECT id FROM house WHERE slug=w.victor_slug), w.outcome, w.description
FROM w
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name,
  start_year=COALESCE(excluded.start_year, war.start_year),
  end_year=COALESCE(excluded.end_year, war.end_year),
  victor_house_id=COALESCE(excluded.victor_house_id, war.victor_house_id),
  outcome=excluded.outcome,
  description=excluded.description,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

WITH b(slug, name, war_slug, year, loc_slug, victor, outcome, description) AS (
  VALUES
   ('battle-of-the-seven-stars','The Battle of the Seven Stars','andal-conquest-of-the-vale',NULL,NULL,'Andals','Royce host defeated','Legendary battle where Artys Arryn defeated Robar II Royce.'),
   ('battle-of-gulltown','The Battle of Gulltown','roberts-rebellion',282,'gulltown','Rebels','Gulltown secured','Jon Arryn and his allies defeated loyalists at Gulltown.'),
   ('battle-of-the-bells','The Battle of the Bells','roberts-rebellion',283,NULL,'Rebels','Rebel victory','Vale forces helped save Robert Baratheon at Stoney Sept.')
)
INSERT INTO battle (slug, name, war_id, year, location_id, victor_side, outcome, description)
SELECT b.slug, b.name, (SELECT id FROM war WHERE slug=b.war_slug), b.year,
       (SELECT id FROM location WHERE slug=b.loc_slug), b.victor, b.outcome, b.description
FROM b
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name,
  war_id=COALESCE(excluded.war_id, battle.war_id),
  year=COALESCE(excluded.year, battle.year),
  location_id=COALESCE(excluded.location_id, battle.location_id),
  victor_side=excluded.victor_side,
  outcome=excluded.outcome,
  description=excluded.description,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

WITH e(slug, name, type, year, loc_slug, war_slug, battle_slug, description) AS (
  VALUES
   ('founding-of-house-arryn','Founding of House Arryn','founding',NULL,'the-eyrie','andal-conquest-of-the-vale','battle-of-the-seven-stars','Artys Arryn founded Andal rule in the Vale.'),
   ('visenya-at-the-eyrie','Visenya Lands at the Eyrie','alliance',1,'the-eyrie','aegons-conquest',NULL,'Sharra Arryn submitted after Visenya flew Vhagar into the Eyrie with young Ronnel.'),
   ('jon-arryn-calls-banners','Jon Arryn Calls His Banners','war',282,'the-eyrie','roberts-rebellion',NULL,'Jon refused Aerys II''s command to surrender Robert and Eddard.'),
   ('jon-arryn-poisoned','Jon Arryn Poisoned','death',298,'kings-landing',NULL,NULL,'Lysa poisoned Jon Arryn at Littlefinger''s urging.'),
   ('lysa-through-moon-door','Lysa Arryn Through the Moon Door','death',300,'moon-door',NULL,NULL,'Petyr Baelish murdered Lysa in the Eyrie.')
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
