-- Martell conflicts and events.

WITH loc(slug, name, type, region, house_slug, descr) AS (
  VALUES
   ('sunspear','Sunspear','castle','Dorne','martell','Seat of House Martell.'),
   ('sandship','The Sandship','castle','Dorne','martell','Old Martell seat later part of Sunspear.'),
   ('water-gardens','The Water Gardens','landmark','Dorne','martell','Palace built by Maron Martell for Daenerys Targaryen.'),
   ('hellholt','The Hellholt','castle','Dorne',NULL,'Dornish castle where Meraxes was shot down.'),
   ('red-mountains','The Red Mountains','region','Dorne',NULL,'Mountain frontier between Dorne, the Reach, and the stormlands.')
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
   ('nymerias-war','Nymeria''s War',NULL,NULL,'martell','Martell unification of Dorne','Nymeria and Mors Martell conquered rival Dornish kings.'),
   ('first-dornish-war','The First Dornish War',4,13,'martell','Dornish independence preserved','Dorne resisted Aegon I and killed Rhaenys and Meraxes.'),
   ('daerons-conquest-of-dorne','Daeron I''s Conquest of Dorne',157,161,'targaryen','Temporary Targaryen conquest then revolt','Daeron I conquered Dorne but could not hold it.'),
   ('roberts-rebellion','Robert''s Rebellion',282,283,'baratheon','Rebel victory','Dorne remained loyal to Aerys through Elia''s marriage to Rhaegar.'),
   ('war-of-the-five-kings','The War of the Five Kings',298,300,NULL,'Lannister-Tyrell regime holds King''s Landing','Dorne entered the war diplomatically through Myrcella''s betrothal.')
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
   ('field-of-fire-dorne','Dornish Guerilla Resistance','first-dornish-war',4,'red-mountains','Dorne','Targaryen occupation frustrated','Dornish forces avoided pitched battle and bled the invaders.'),
   ('rhaenys-at-the-hellholt','Rhaenys at the Hellholt','first-dornish-war',10,'hellholt','Dorne','Meraxes killed','A scorpion bolt killed Meraxes and Rhaenys during the war.'),
   ('daeron-in-dorne','Daeron I in Dorne','daerons-conquest-of-dorne',158,'sunspear','Targaryen','Dorne occupied','Daeron I accepted Dornish submission.'),
   ('battle-of-the-trident','The Battle of the Trident','roberts-rebellion',283,'the-trident','Rebels','Rebel victory','Lewyn Martell died serving the Kingsguard.'),
   ('sack-of-kings-landing','The Sack of King''s Landing','roberts-rebellion',283,'kings-landing','Rebels','Rebel victory','Elia Martell and her children were murdered.')
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
   ('nymeria-burns-ships','Nymeria Burns Her Ships','founding',NULL,'sandship','nymerias-war',NULL,'Nymeria burned the Rhoynar ships after joining Mors Martell.'),
   ('dorne-joins-realm','Dorne Joins the Seven Kingdoms','alliance',187,'sunspear',NULL,NULL,'Daeron II''s marriage alliances peacefully brought Dorne into the realm.'),
   ('elia-and-children-murdered','Elia and Her Children Murdered','death',283,'kings-landing','roberts-rebellion','sack-of-kings-landing','Elia, Rhaenys, and Aegon were murdered during the Sack.'),
   ('oberyn-trial-by-combat','Oberyn''s Trial by Combat','death',300,'kings-landing',NULL,NULL,'Oberyn died fighting Gregor Clegane as Tyrion''s champion.'),
   ('quentyn-burned','Quentyn Martell Burned','death',300,NULL,NULL,NULL,'Quentyn died after attempting to claim one of Daenerys''s dragons.')
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
