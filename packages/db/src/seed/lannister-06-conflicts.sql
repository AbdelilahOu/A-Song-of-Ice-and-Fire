-- Lannister locations, wars, battles, and timeline events. Idempotent.

WITH loc(slug, name, type, region, house_slug, descr) AS (
  VALUES
   ('casterly-rock','Casterly Rock','castle','The Westerlands','lannister','Ancient fortress and seat of House Lannister.'),
   ('lannisport','Lannisport','city','The Westerlands','lannister','Great port city beneath Casterly Rock.'),
   ('red-fork','The Red Fork','landmark','The Riverlands',NULL,'Fork of the Trident where Jason Lannister was slain during the Dance.'),
   ('lakeshore','The Lakeshore','landmark','The Riverlands',NULL,'Site of the bloody Battle by the Lakeshore during the Dance.'),
   ('fair-isle','Fair Isle','island','The Westerlands',NULL,'Island off the western coast contested by Lannisters and ironborn.'),
   ('wendwater-bridge','Wendwater Bridge','landmark','The Crownlands',NULL,'Battlefield of the Fourth Blackfyre Rebellion.'),
   ('castamere','Castamere','castle','The Westerlands',NULL,'Former seat of House Reyne, destroyed by Tywin Lannister.'),
   ('tarbeck-hall','Tarbeck Hall','castle','The Westerlands',NULL,'Seat of House Tarbeck, destroyed in Tywin''s campaign.'),
   ('oxcross','Oxcross','town','The Westerlands',NULL,'Site of Robb Stark''s surprise attack on Stafford Lannister.'),
   ('riverrun','Riverrun','castle','The Riverlands','tully','Seat of House Tully.'),
   ('blackwater-bay','Blackwater Bay','landmark','The Crownlands',NULL,'Bay outside King''s Landing, site of Stannis Baratheon''s defeat.'),
   ('purple-wedding','The Purple Wedding','other','The Crownlands',NULL,'Royal wedding feast where Joffrey Baratheon was poisoned.')
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
   ('faith-militant-uprising','The Faith Militant Uprising',37,48,'targaryen','Royal victory','A religious rebellion against the early Targaryen monarchy; Lannister politics touched the western front.'),
   ('reyne-tarbeck-revolt','The Reyne-Tarbeck Revolt',261,261,'lannister','Lannister victory','Tywin Lannister annihilated Houses Reyne and Tarbeck after years of defiance under Tytos.'),
   ('roberts-rebellion','Robert''s Rebellion',282,283,'baratheon','Rebel victory','The rebellion that overthrew Aerys II and ended Targaryen rule.'),
   ('greyjoy-rebellion','The Greyjoy Rebellion',289,289,'baratheon','Royal victory','Balon Greyjoy''s failed rebellion against the Iron Throne.'),
   ('war-of-the-five-kings','The War of the Five Kings',298,300,NULL,'Lannister-Tyrell regime holds King''s Landing','A multi-sided civil war after Robert Baratheon''s death.')
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
   ('battle-of-the-red-fork','The Battle of the Red Fork','dance-of-the-dragons',130,'red-fork','Blacks','Black victory','Jason Lannister was slain and the western host lost momentum in the riverlands.'),
   ('battle-by-the-lakeshore','The Battle by the Lakeshore','dance-of-the-dragons',130,'lakeshore','Blacks','Black victory','The remaining Lannister host was shattered in one of the Dance''s bloodiest battles.'),
   ('battle-of-fair-isle','The Battle of Fair Isle','dance-of-the-dragons',132,'fair-isle','Ironborn','Ironborn victory','Erwin Lannister''s naval attempt to retake Fair Isle ended in disaster.'),
   ('battle-of-wendwater-bridge','The Battle of Wendwater Bridge','war-of-ninepenny-kings',236,'wendwater-bridge','Targaryen loyalists','Loyalist victory','Battle of the Fourth Blackfyre Rebellion where Tywald and Tion Lannister died.'),
   ('fall-of-castamere','The Fall of Castamere','reyne-tarbeck-revolt',261,'castamere','Lannister','House Reyne extinguished','Tywin trapped the Reynes below Castamere and flooded the mines.'),
   ('fall-of-tarbeck-hall','The Fall of Tarbeck Hall','reyne-tarbeck-revolt',261,'tarbeck-hall','Lannister','House Tarbeck extinguished','Tywin crushed House Tarbeck before turning on Castamere.'),
   ('sack-of-kings-landing','The Sack of King''s Landing','roberts-rebellion',283,'kings-landing','Rebels','Rebel victory','Tywin Lannister''s host entered and sacked the capital as Aerys II fell.'),
   ('battle-of-oxcross','The Battle of Oxcross','war-of-the-five-kings',299,'oxcross','Northmen','Northern victory','Robb Stark surprised Stafford Lannister''s new host in the west.'),
   ('battle-of-the-blackwater','The Battle of the Blackwater','war-of-the-five-kings',299,'blackwater-bay','Lannister-Tyrell','King''s Landing held','Lannister and Tyrell forces defeated Stannis Baratheon outside the capital.')
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
   ('lannisters-bend-the-knee','Loren I Bends the Knee','alliance',1,NULL,'aegons-conquest',NULL,'After the Field of Fire, Loren I submitted to Aegon and remained Lord of Casterly Rock.'),
   ('tyland-named-hand','Tyland Lannister Named Hand','other',131,'kings-landing',NULL,NULL,'Aegon III made Tyland Lannister Hand during the regency.'),
   ('tywin-becomes-hand','Tywin Lannister Becomes Hand','other',262,'kings-landing',NULL,NULL,'Aerys II named the young Tywin Lannister Hand of the King.'),
   ('joanna-dies-birthing-tyrion','Joanna Dies Birthing Tyrion','death',273,'casterly-rock',NULL,NULL,'Joanna Lannister died giving birth to Tyrion.'),
   ('bread-riots-of-kings-landing','The Bread Riots of King''s Landing','other',299,'kings-landing','war-of-the-five-kings',NULL,'Tyrek Lannister vanished during the riot while escorting Princess Myrcella.'),
   ('joffreys-wedding-poisoning','Joffrey Baratheon Poisoned','death',300,'purple-wedding','war-of-the-five-kings',NULL,'King Joffrey died at his wedding feast, and Tyrion was accused of the murder.'),
   ('tyrion-kills-tywin','Tyrion Kills Tywin','death',300,'kings-landing','war-of-the-five-kings',NULL,'Tyrion escaped the black cells and killed Tywin with a crossbow.'),
   ('kevan-assassinated','Kevan Lannister Assassinated','death',300,'kings-landing',NULL,NULL,'Varys murdered Kevan Lannister to destabilize the royal government.')
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
