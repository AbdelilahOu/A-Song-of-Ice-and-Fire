-- Deaths in and around the Lannister line. Idempotent by member_id.

WITH d(mslug, yr, loc, cause, killer, battle, descr, confirmed) AS (
  VALUES
   ('lyman-lannister',59,'casterly-rock','Died of the Shivers',NULL,NULL,'Lord Lyman died during the Shivers plague.',1),
   ('jason-lannister-dance',130,'red-fork','Slain in battle',NULL,'battle-of-the-red-fork','Killed during the Dance by Pate of Longleaf.',1),
   ('erwin-lannister',132,'fair-isle','Slain in battle',NULL,'battle-of-fair-isle','Died in the failed Lannister naval attack against Dalton Greyjoy.',1),
   ('tyland-lannister',133,'kings-landing','Died of Winter Fever',NULL,NULL,'Died after ordering a quarantine during the Winter Fever in King''s Landing.',1),
   ('damon-lannister-grey-lion',209,'casterly-rock','Died during the Great Spring Sickness',NULL,NULL,'The Grey Lion died in the Great Spring Sickness.',1),
   ('tywald-lannister',236,'wendwater-bridge','Died of wounds',NULL,'battle-of-wendwater-bridge','Knighted on his deathbed after the Battle of Wendwater Bridge.',1),
   ('tion-lannister-son-of-gerold',236,'wendwater-bridge','Slain in battle',NULL,'battle-of-wendwater-bridge','Killed during the Fourth Blackfyre Rebellion.',1),
   ('tytos-lannister',267,'casterly-rock','Burst heart',NULL,NULL,'Collapsed while climbing steps to visit his mistress.',1),
   ('joanna-lannister',273,'casterly-rock','Died in childbirth',NULL,NULL,'Died giving birth to Tyrion Lannister.',1),
   ('tygett-lannister',285,'casterly-rock','Died of a pox',NULL,NULL,'Died from a pox before the main saga.',1),
   ('robert-baratheon',298,'kings-landing','Mortal wounds from a boar hunt',NULL,NULL,'Died after a hunting accident arranged through Lannister intrigue.',1),
   ('stafford-lannister',299,'oxcross','Slain in battle',NULL,'battle-of-oxcross','Killed when Robb Stark surprised the new westermen host at Oxcross.',1),
   ('willem-lannister',299,'riverrun','Murdered','rickard-karstark',NULL,'Murdered in captivity at Riverrun on Rickard Karstark''s orders.',1),
   ('joffrey-baratheon',300,'purple-wedding','Poisoned',NULL,NULL,'Poisoned at his wedding feast.',1),
   ('tywin-lannister',300,'kings-landing','Shot with a crossbow','tyrion-lannister',NULL,'Killed by Tyrion after Tyrion escaped the black cells.',1),
   ('kevan-lannister',300,'kings-landing','Murdered','varys',NULL,'Shot by Varys in the Red Keep to destabilize the realm.',1),
   ('gerion-lannister',NULL,NULL,'Missing in Essos',NULL,NULL,'Vanished while searching for Brightroar and is presumed dead.',0),
   ('tyrek-lannister',NULL,'kings-landing','Missing during riot',NULL,NULL,'Vanished during the bread riots and is presumed dead by many.',0)
)
INSERT INTO death (member_id, year, location_id, cause, killer_id, battle_id, description, is_confirmed)
SELECT m.id, d.yr,
       (SELECT id FROM location WHERE slug=d.loc),
       d.cause,
       (SELECT id FROM member WHERE slug=d.killer),
       (SELECT id FROM battle WHERE slug=d.battle),
       d.descr,
       d.confirmed
FROM d JOIN member m ON m.slug=d.mslug
WHERE true
ON CONFLICT(member_id) DO UPDATE SET
  year=COALESCE(excluded.year, death.year),
  location_id=COALESCE(excluded.location_id, death.location_id),
  cause=excluded.cause,
  killer_id=COALESCE(excluded.killer_id, death.killer_id),
  battle_id=COALESCE(excluded.battle_id, death.battle_id),
  description=excluded.description,
  is_confirmed=excluded.is_confirmed,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));
