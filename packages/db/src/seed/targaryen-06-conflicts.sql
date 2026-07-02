-- Targaryen-era locations, wars, battles, and timeline events. Idempotent
-- (UPSERT by slug). Foreign keys resolved by slug subqueries.

-- Locations (upsert by slug; controlling house optional).
WITH loc(slug, name, type, region, house_slug) AS (
  VALUES
   ('kings-landing','King''s Landing','city','The Crownlands','targaryen'),
   ('dragonstone','Dragonstone','castle','The Crownlands','targaryen'),
   ('summerhall','Summerhall','castle','The Stormlands','targaryen'),
   ('gods-eye','The God''s Eye','landmark','The Riverlands',NULL),
   ('rooks-rest','Rook''s Rest','castle','The Crownlands',NULL),
   ('tumbleton','Tumbleton','town','The Reach',NULL),
   ('the-trident','The Trident','landmark','The Riverlands',NULL),
   ('storms-end','Storm''s End','castle','The Stormlands','baratheon'),
   ('redgrass-field','The Redgrass Field','landmark','The Crownlands',NULL)
)
INSERT INTO location (slug, name, type, region, controlling_house_id)
SELECT loc.slug, loc.name, loc.type, loc.region, (SELECT id FROM house WHERE slug=loc.house_slug)
FROM loc
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name, type=excluded.type, region=COALESCE(excluded.region, location.region),
  controlling_house_id=COALESCE(excluded.controlling_house_id, location.controlling_house_id),
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

-- Wars (upsert by slug).
WITH w(slug, name, sy, ey, victor_slug, outcome, description) AS (
  VALUES
   ('aegons-conquest','Aegon''s Conquest',-2,1,'targaryen','Six kingdoms bent the knee','Aegon Targaryen and his sisters united six of the Seven Kingdoms by fire and dragon.'),
   ('dance-of-the-dragons','The Dance of the Dragons',129,131,'targaryen','Pyrrhic victory for the blacks','The Targaryen civil war between the greens of Aegon II and the blacks of Rhaenyra that all but destroyed the dragons.'),
   ('first-blackfyre-rebellion','The First Blackfyre Rebellion',195,196,'targaryen','Loyalist victory','Daemon Blackfyre''s bid for the throne, broken on the Redgrass Field.'),
   ('war-of-ninepenny-kings','The War of the Ninepenny Kings',259,260,'targaryen','Band of Nine defeated','The last Blackfyre pretender died on the Stepstones, ending the male Blackfyre line.')
)
INSERT INTO war (slug, name, start_year, end_year, victor_house_id, outcome, description)
SELECT w.slug, w.name, w.sy, w.ey, (SELECT id FROM house WHERE slug=w.victor_slug), w.outcome, w.description
FROM w
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name, start_year=excluded.start_year, end_year=excluded.end_year,
  victor_house_id=COALESCE(excluded.victor_house_id, war.victor_house_id),
  outcome=excluded.outcome, description=excluded.description,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

-- Battles (upsert by slug).
WITH b(slug, name, war_slug, year, loc_slug, victor, outcome, description) AS (
  VALUES
   ('field-of-fire','The Field of Fire','aegons-conquest',-2,NULL,'Targaryen','Targaryen victory','Aegon''s three dragons burned the host of the Reach and the Westerlands; the only battle where all three flew together.'),
   ('battle-of-rooks-rest','The Battle of Rook''s Rest','dance-of-the-dragons',129,'rooks-rest','Greens','Green victory','Aegon II and Aemond ambushed Rhaenys and Meleys; the Queen Who Never Was fell here.'),
   ('battle-of-the-gullet','The Battle of the Gullet','dance-of-the-dragons',130,NULL,'Blacks','Costly black victory','A savage sea-and-sky battle against the Triarchy in which Jacaerys Velaryon died.'),
   ('first-battle-of-tumbleton','The First Battle of Tumbleton','dance-of-the-dragons',130,'tumbleton','Greens','Green victory by treason','The Two Betrayers turned their dragons against Rhaenyra''s cause and sacked the town.'),
   ('second-battle-of-tumbleton','The Second Battle of Tumbleton','dance-of-the-dragons',130,'tumbleton','Blacks','Black victory','Four dragons died as the black host retook Tumbleton; Daeron the Daring perished.'),
   ('battle-above-the-gods-eye','The Battle Above the Gods Eye','dance-of-the-dragons',130,'gods-eye','None','Mutual destruction','Daemon on Caraxes fell upon Aemond and Vhagar over the lake; both princes and Vhagar died.'),
   ('redgrass-field','The Battle of the Redgrass Field','first-blackfyre-rebellion',196,'redgrass-field','Loyalists','Loyalist victory','Bloodraven''s archers slew Daemon Blackfyre and his sons, ending the first rebellion.'),
   ('battle-of-the-trident','The Battle of the Trident','roberts-rebellion',283,'the-trident','Rebels','Rebel victory','Robert Baratheon slew Prince Rhaegar in the ford, breaking the Targaryen cause.')
)
INSERT INTO battle (slug, name, war_id, year, location_id, victor_side, outcome, description)
SELECT b.slug, b.name, (SELECT id FROM war WHERE slug=b.war_slug), b.year,
       (SELECT id FROM location WHERE slug=b.loc_slug), b.victor, b.outcome, b.description
FROM b
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name, war_id=COALESCE(excluded.war_id, battle.war_id), year=excluded.year,
  location_id=COALESCE(excluded.location_id, battle.location_id),
  victor_side=excluded.victor_side, outcome=excluded.outcome, description=excluded.description,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));

-- Timeline events (upsert by slug).
WITH e(slug, name, type, year, loc_slug, description) AS (
  VALUES
   ('aegons-landing','Aegon''s Landing','founding',-2,'kings-landing','The Targaryens came ashore at the mouth of the Blackwater, where King''s Landing would rise.'),
   ('aegons-coronation','The Coronation of Aegon I','coronation',1,NULL,'Aegon was anointed King of the Andals, the Rhoynar, and the First Men; the calendar begins.'),
   ('death-of-lucerys','The Death of Lucerys Velaryon','death',129,'storms-end','Vhagar devoured Arrax and Lucerys over Shipbreaker Bay, turning cold war into open Dance.'),
   ('blood-and-cheese','Blood and Cheese','betrayal',130,'kings-landing','Two hirelings of Daemon murdered Prince Jaehaerys before Queen Helaena in vengeance for Lucerys.'),
   ('storming-of-the-dragonpit','The Storming of the Dragonpit','battle',130,'kings-landing','A maddened mob broke into the Dragonpit and slew the dragons chained within.'),
   ('tragedy-at-summerhall','The Tragedy at Summerhall','death',259,'summerhall','King Aegon V and Prince Duncan died in a fire meant to hatch dragons, the night Rhaegar was born.'),
   ('sack-of-kings-landing','The Sack of King''s Landing','battle',283,'kings-landing','Tywin Lannister''s host stormed the city; Elia Martell and Rhaegar''s children were murdered.')
)
INSERT INTO event (slug, name, type, year, location_id, description)
SELECT e.slug, e.name, e.type, e.year, (SELECT id FROM location WHERE slug=e.loc_slug), e.description
FROM e
WHERE true
ON CONFLICT(slug) DO UPDATE SET
  name=excluded.name, type=excluded.type, year=excluded.year,
  location_id=COALESCE(excluded.location_id, event.location_id),
  description=excluded.description, updated_at=(cast(unixepoch('subsecond') * 1000 as integer));
