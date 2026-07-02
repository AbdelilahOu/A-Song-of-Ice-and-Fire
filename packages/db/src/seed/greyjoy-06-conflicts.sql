-- Greyjoy conflicts and events.

WITH loc(slug, name, type, region, house_slug, descr) AS (
  VALUES
   ('pyke','Pyke','castle','Iron Islands','greyjoy','Seat of House Greyjoy.'),
   ('old-wyk','Old Wyk','island','Iron Islands',NULL,'Sacred island of the ironborn and site of the kingsmoot.'),
   ('fair-isle','Fair Isle','island','The Westerlands',NULL,'Western island raided and fought over by ironborn.'),
   ('lordsport','Lordsport','town','Iron Islands','greyjoy','Port town on Pyke.'),
   ('winterfell','Winterfell','castle','The North','stark','Seat of House Stark, captured by Theon Greyjoy.')
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
   ('aegons-conquest','Aegon''s Conquest',-2,1,'targaryen','Six kingdoms bent the knee','Aegon destroyed House Hoare and allowed the ironborn to choose Vickon Greyjoy.'),
   ('dance-of-the-dragons','The Dance of the Dragons',129,131,'targaryen','Pyrrhic victory for the blacks','Dalton Greyjoy raided the westerlands for the blacks.'),
   ('greyjoy-rebellion','The Greyjoy Rebellion',289,289,'baratheon','Royal victory','Balon Greyjoy''s first attempt at independence failed.'),
   ('war-of-the-five-kings','The War of the Five Kings',298,300,NULL,'Lannister-Tyrell regime holds King''s Landing','Balon renewed ironborn independence and invaded the North.')
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
   ('burning-of-harrenhal','The Burning of Harrenhal','aegons-conquest',-2,'harrenhal','Targaryen','House Hoare destroyed','Harren the Black died and ironborn rule over the riverlands ended.'),
   ('battle-of-fair-isle','The Battle of Fair Isle','dance-of-the-dragons',132,'fair-isle','Ironborn','Ironborn victory','Erwin Lannister failed to dislodge Dalton Greyjoy''s raiders.'),
   ('battle-off-fair-isle','The Battle off Fair Isle','greyjoy-rebellion',289,'fair-isle','Royal fleet','Iron Fleet destroyed','Stannis Baratheon smashed Victarion''s Iron Fleet.'),
   ('siege-of-pyke','The Siege of Pyke','greyjoy-rebellion',289,'pyke','Royal forces','Balon defeated','Robert, Eddard, and their allies stormed Pyke.'),
   ('capture-of-winterfell','The Capture of Winterfell','war-of-the-five-kings',299,'winterfell','Ironborn','Winterfell taken','Theon Greyjoy seized Winterfell with a small ironborn force.')
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
   ('vickon-chosen','Vickon Greyjoy Chosen','alliance',1,'pyke','aegons-conquest',NULL,'The ironborn chose Vickon Greyjoy to rule after House Hoare fell.'),
   ('dalton-murdered','Dalton Greyjoy Murdered','death',133,'pyke','dance-of-the-dragons',NULL,'The Red Kraken was murdered by one of his salt wives.'),
   ('theon-taken-ward','Theon Taken as Ward','other',289,'winterfell','greyjoy-rebellion',NULL,'Theon was taken to Winterfell as Eddard Stark''s ward and hostage.'),
   ('balon-crowned-again','Balon Crowns Himself Again','coronation',299,'pyke','war-of-the-five-kings',NULL,'Balon declared himself King of the Isles and the North.'),
   ('kingsmoot-of-old-wyk','The Kingsmoot of Old Wyk','coronation',300,'old-wyk','war-of-the-five-kings',NULL,'Euron Greyjoy won the kingsmoot after Balon''s death.')
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
