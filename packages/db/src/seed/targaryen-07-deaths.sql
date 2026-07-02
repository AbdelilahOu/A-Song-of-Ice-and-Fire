-- Deaths of the Targaryen line. Idempotent (UPSERT by member_id). Killer,
-- battle, and location resolved by slug; NULL where unknown/not modelled.
WITH d(mslug, yr, loc, cause, killer, battle, descr) AS (
  VALUES
   ('rhaenys-targaryen',10,NULL,'Shot down over Dorne',NULL,NULL,'Meraxes was felled by a scorpion bolt over the Hellholt; Rhaenys fell with her.'),
   ('aegon-uncrowned-targaryen',43,'gods-eye','Slain in battle','maegor-i-targaryen',NULL,'Killed by his uncle Maegor at the Battle Beneath the God''s Eye.'),
   ('rhaenys-queen-who-never-was',129,'rooks-rest','Slain in battle',NULL,'battle-of-rooks-rest','Meleys was brought down by Sunfyre and Vhagar at Rook''s Rest.'),
   ('lucerys-velaryon',129,'storms-end','Devoured by Vhagar','aemond-targaryen',NULL,'Aemond''s Vhagar caught Arrax and Lucerys in a storm over Shipbreaker Bay.'),
   ('jaehaerys-targaryen-son',130,'kings-landing','Murdered',NULL,NULL,'Slain in his bed by the assassins Blood and Cheese.'),
   ('jacaerys-velaryon',130,NULL,'Fell in battle',NULL,'battle-of-the-gullet','Died leaping onto an enemy ship as Vermax was dragged down in the Gullet.'),
   ('daemon-targaryen',130,'gods-eye','Slain slaying Aemond',NULL,'battle-above-the-gods-eye','Leapt from Caraxes onto Vhagar and drove Dark Sister through Aemond''s eye; both fell into the lake.'),
   ('aemond-targaryen',130,'gods-eye','Slain in battle','daemon-targaryen','battle-above-the-gods-eye','Killed by Daemon above the God''s Eye as Vhagar and Caraxes destroyed each other.'),
   ('daeron-targaryen-daring',130,'tumbleton','Slain in battle',NULL,'second-battle-of-tumbleton','Cut down amid the chaos of the second sack of Tumbleton.'),
   ('joffrey-velaryon',130,'kings-landing','Killed attempting to fly',NULL,NULL,'Died trying to reach his dragon as the mob stormed the Dragonpit.'),
   ('rhaenyra-targaryen',130,'dragonstone','Devoured by Sunfyre','aegon-ii-targaryen',NULL,'Aegon II fed his half-sister to his dragon Sunfyre on the steps of Dragonstone.'),
   ('helaena-targaryen',130,'kings-landing','Took her own life',NULL,NULL,'Grief-maddened, she leapt from the Red Keep onto the spikes below.'),
   ('aegon-ii-targaryen',131,'kings-landing','Poisoned',NULL,NULL,'Poisoned by his own men to end the war and seat Aegon III.'),
   ('aegon-iii-targaryen',157,'kings-landing','Died of illness',NULL,NULL,'The Broken King wasted away, haunted his whole life by the Dance.'),
   ('daeron-i-targaryen',161,NULL,'Slain in Dorne',NULL,NULL,'Killed beneath a peace banner during the Dornish uprising he had provoked.'),
   ('baelor-i-targaryen',171,'kings-landing','Died after fasting',NULL,NULL,'The Blessed died at the end of one of his long, pious fasts.'),
   ('daemon-blackfyre',196,'redgrass-field','Slain in battle','brynden-rivers','redgrass-field','Cut down with his twin sons by Bloodraven''s archers on the Redgrass Field.'),
   ('baelor-breakspear',209,NULL,'Died of injuries',NULL,NULL,'Struck down defending his brother in the melee at the Tourney at Ashford.'),
   ('aerion-brightflame',232,'kings-landing','Drank wildfire',NULL,NULL,'Believing it would transform him into a dragon, he drank a cup of wildfire.'),
   ('maekar-i-targaryen',233,NULL,'Slain in battle',NULL,NULL,'Killed storming the castle of a rebel lord in the Peake Uprising.'),
   ('aegon-v-targaryen',259,'summerhall','Perished at Summerhall',NULL,NULL,'Consumed by the fire he kindled at Summerhall in hope of hatching dragons.'),
   ('duncan-targaryen',259,'summerhall','Perished at Summerhall',NULL,NULL,'Died beside his father in the flames of Summerhall.'),
   ('rhaegar-targaryen',283,'the-trident','Slain in battle','robert-baratheon','battle-of-the-trident','Fell to Robert Baratheon''s warhammer in the waters of the Trident.'),
   ('elia-martell',283,'kings-landing','Murdered',NULL,NULL,'Killed with her children during the Sack of King''s Landing.'),
   ('rhaenys-targaryen-younger',283,'kings-landing','Murdered',NULL,NULL,'Slain during the Sack of King''s Landing.'),
   ('aegon-targaryen-son',283,'kings-landing','Murdered',NULL,NULL,'Killed as an infant during the Sack of King''s Landing.'),
   ('aerys-ii-targaryen',283,'kings-landing','Slain by the Kingsguard','jaime-lannister',NULL,'The Mad King was cut down by Jaime Lannister as the city fell.'),
   ('rhaella-targaryen',284,'dragonstone','Died in childbirth',NULL,NULL,'Died on Dragonstone giving birth to Daenerys as a storm broke.'),
   ('viserys-targaryen',298,NULL,'Molten gold',NULL,NULL,'Khal Drogo crowned the Beggar King with a cauldron of molten gold in Vaes Dothrak.'),
   ('aemon-maester',300,NULL,'Died of old age',NULL,NULL,'Maester Aemon died at sea, near a century old, having outlived his whole house save Daenerys.')
)
INSERT INTO death (member_id, year, location_id, cause, killer_id, battle_id, description, is_confirmed)
SELECT m.id, d.yr,
       (SELECT id FROM location WHERE slug=d.loc),
       d.cause,
       (SELECT id FROM member WHERE slug=d.killer),
       (SELECT id FROM battle WHERE slug=d.battle),
       d.descr, 1
FROM d JOIN member m ON m.slug=d.mslug
WHERE true
ON CONFLICT(member_id) DO UPDATE SET
  year=excluded.year,
  location_id=COALESCE(excluded.location_id, death.location_id),
  cause=excluded.cause,
  killer_id=COALESCE(excluded.killer_id, death.killer_id),
  battle_id=COALESCE(excluded.battle_id, death.battle_id),
  description=excluded.description,
  updated_at=(cast(unixepoch('subsecond') * 1000 as integer));
