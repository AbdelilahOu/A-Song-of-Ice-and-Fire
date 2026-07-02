-- Event and war participants for the Targaryen era. Idempotent via NOT EXISTS.

-- Event participants (member).
WITH ep(event_slug, member_slug, role) AS (
  VALUES
   ('aegons-coronation','aegon-i-targaryen','subject'),
   ('death-of-lucerys','lucerys-velaryon','victim'),
   ('death-of-lucerys','aemond-targaryen','instigator'),
   ('blood-and-cheese','jaehaerys-targaryen-son','victim'),
   ('blood-and-cheese','daemon-targaryen','instigator'),
   ('blood-and-cheese','helaena-targaryen','witness'),
   ('tragedy-at-summerhall','aegon-v-targaryen','victim'),
   ('tragedy-at-summerhall','duncan-targaryen','victim'),
   ('tragedy-at-summerhall','rhaegar-targaryen','subject'),
   ('sack-of-kings-landing','elia-martell','victim'),
   ('sack-of-kings-landing','rhaenys-targaryen-younger','victim'),
   ('sack-of-kings-landing','aegon-targaryen-son','victim'),
   ('storming-of-the-dragonpit','joffrey-velaryon','victim'),
   ('aegons-landing','aegon-i-targaryen','subject')
)
INSERT INTO event_participant (event_id, member_id, role)
SELECT ev.id, m.id, ep.role
FROM ep JOIN event ev ON ev.slug=ep.event_slug JOIN member m ON m.slug=ep.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM event_participant x WHERE x.event_id=ev.id AND x.member_id=m.id
);

-- War participants (member, side).
WITH wp(war_slug, member_slug, side, role) AS (
  VALUES
   ('dance-of-the-dragons','rhaenyra-targaryen','blacks','commander'),
   ('dance-of-the-dragons','daemon-targaryen','blacks','commander'),
   ('dance-of-the-dragons','aegon-ii-targaryen','greens','commander'),
   ('dance-of-the-dragons','aemond-targaryen','greens','commander'),
   ('aegons-conquest','aegon-i-targaryen','targaryen','attacker'),
   ('aegons-conquest','visenya-targaryen','targaryen','attacker'),
   ('aegons-conquest','rhaenys-targaryen','targaryen','attacker'),
   ('first-blackfyre-rebellion','daemon-blackfyre','blackfyre','commander'),
   ('first-blackfyre-rebellion','daeron-ii-targaryen','loyalists','defender'),
   ('first-blackfyre-rebellion','brynden-rivers','loyalists','commander'),
   ('roberts-rebellion','rhaegar-targaryen','loyalists','commander'),
   ('roberts-rebellion','aerys-ii-targaryen','loyalists','defender')
)
INSERT INTO war_participant (war_id, member_id, side, role)
SELECT w.id, m.id, wp.side, wp.role
FROM wp JOIN war w ON w.slug=wp.war_slug JOIN member m ON m.slug=wp.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM war_participant x WHERE x.war_id=w.id AND x.member_id=m.id
);
