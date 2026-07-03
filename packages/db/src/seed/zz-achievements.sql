-- Notable deeds for members and dragons. Runs after all member/dragon seeds
-- (alphabetical). Idempotent via NOT EXISTS guards on (subject, title).

-- Member achievements.
WITH ma(member_slug, title, year, category, description, sort_order) AS (
  VALUES
   -- House Targaryen
   ('aegon-i-targaryen','Aegon''s Conquest',-2,'military','Landed at the mouth of the Blackwater with his sisters and three dragons and set out to unite the Seven Kingdoms.',1),
   ('aegon-i-targaryen','Forged the Iron Throne',1,'political','Had the swords of his fallen enemies beaten and fused into a throne by the fire of Balerion.',2),
   ('aegon-i-targaryen','Crowned in Oldtown',1,'political','Anointed by the High Septon as the first Targaryen King of the Seven Kingdoms.',3),
   ('visenya-targaryen','Founded the Kingsguard',10,'political','Devised the order of seven sworn knights to guard the king, modeled on the Night''s Watch vows.',1),
   ('maegor-i-targaryen','Completed the Red Keep',45,'construction','Finished the great castle of King''s Landing, then put its builders to death to keep its secrets.',1),
   ('jaehaerys-i-targaryen','The Old King''s Peace',NULL,'political','Reigned fifty-five years, the longest of any Targaryen, remembered as an age of prosperity and law.',1),
   ('jaehaerys-i-targaryen','Built the Kingsroad',NULL,'construction','Oversaw the great roads and reforms that knit the realm together under one crown.',2),
   ('rhaenyra-targaryen','Named Heir to the Throne',105,'dynastic','Proclaimed heir by her father Viserys I, the first woman named to inherit the Iron Throne.',1),
   ('rhaenyra-targaryen','Crowned at Dragonstone',129,'political','Declared queen by her supporters at the outset of the Dance of the Dragons.',2),
   ('aegon-ii-targaryen','Crowned at King''s Landing',129,'political','Set upon the Iron Throne by the green council against his half-sister''s claim.',1),
   ('daenerys-targaryen','Mother of Dragons',298,'dragon','Walked into her husband''s funeral pyre and emerged unburnt with three living dragons.',1),
   ('daenerys-targaryen','Breaker of Chains',300,'political','Freed the slaves of Astapor, Yunkai, and Meereen across Slaver''s Bay.',2),
   -- House Stark
   ('brandon-the-builder','Raised the Wall',NULL,'construction','By legend, built the Wall and the castle of Winterfell in the Age of Heroes.',1),
   ('torrhen-stark','The King Who Knelt',1,'political','Bent the knee to Aegon I rather than see the North burn, trading a crown for his people''s lives.',1),
   ('cregan-stark','The Hour of the Wolf',130,'military','Marched south with a northern host at the close of the Dance to bring traitors to the king''s justice.',1),
   ('cregan-stark','Hand for a Day',131,'political','Served as Hand of the King for a single day to see justice done, then returned to the North.',2),
   ('ned-stark','Tower of Joy',283,'military','Fought Ser Arthur Dayne and the last of the Kingsguard at the war''s end and found his dying sister.',1),
   ('ned-stark','Hand of the King',298,'political','Named Hand by Robert Baratheon and rode south to King''s Landing.',2),
   ('robb-stark','King in the North',298,'political','Proclaimed King in the North and the Trident by his bannermen after his father''s arrest.',1),
   ('robb-stark','Battle of the Whispering Wood',298,'military','Sprang a night ambush that shattered a Lannister host and captured Ser Jaime Lannister.',2),
   ('jon-snow','Took the Black',298,'political','Swore the vows of the Night''s Watch and joined the black brothers at Castle Black.',1),
   ('jon-snow','Lord Commander',299,'political','Chosen the youngest Lord Commander of the Night''s Watch in living memory.',2)
)
INSERT INTO achievement (member_id, title, year, category, description, sort_order)
SELECT m.id, ma.title, ma.year, ma.category, ma.description, ma.sort_order
FROM ma JOIN member m ON m.slug = ma.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM achievement x WHERE x.member_id = m.id AND x.title = ma.title
);

-- Dragon achievements.
WITH da(dragon_slug, title, year, category, description, sort_order) AS (
  VALUES
   ('balerion','Forged the Iron Throne',1,'dragon','His fire beat the surrendered swords of Westeros into Aegon''s throne.',1),
   ('vhagar','Slew Arrax',129,'dragon','Killed Lucerys Velaryon and his dragon over Storm''s End, opening the Dance of the Dragons.',1),
   ('caraxes','Killed Vhagar',130,'dragon','Locked in battle above the Gods Eye and dragged the greatest dragon of the age to its death.',1),
   ('meleys','Fell at Rook''s Rest',129,'dragon','Died with her rider fighting Sunfyre and Vhagar in the first great dragon battle of the Dance.',1),
   ('sunfyre','Devoured a Queen',130,'dragon','Consumed Queen Rhaenyra Targaryen on Dragonstone before the eyes of her son.',1),
   ('drogon','First Dragon in a Century',298,'dragon','Hatched at the Dothraki sea, the first living dragon seen in Westeros in over a hundred years.',1)
)
INSERT INTO achievement (dragon_id, title, year, category, description, sort_order)
SELECT d.id, da.title, da.year, da.category, da.description, da.sort_order
FROM da JOIN dragon d ON d.slug = da.dragon_slug
WHERE NOT EXISTS (
  SELECT 1 FROM achievement x WHERE x.dragon_id = d.id AND x.title = da.title
);
