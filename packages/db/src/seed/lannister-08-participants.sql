-- Lannister event, war, and battle participants. Idempotent via NOT EXISTS.

WITH ep(event_slug, member_slug, role, notes) AS (
  VALUES
   ('lannisters-bend-the-knee','loren-i-lannister','subject',NULL),
   ('tyland-named-hand','tyland-lannister','subject',NULL),
   ('tywin-becomes-hand','tywin-lannister','subject',NULL),
   ('joanna-dies-birthing-tyrion','joanna-lannister','victim',NULL),
   ('joanna-dies-birthing-tyrion','tyrion-lannister','subject',NULL),
   ('bread-riots-of-kings-landing','tyrek-lannister','victim',NULL),
   ('bread-riots-of-kings-landing','myrcella-baratheon','witness',NULL),
   ('joffreys-wedding-poisoning','joffrey-baratheon','victim',NULL),
   ('joffreys-wedding-poisoning','tyrion-lannister','other','Accused of the murder.'),
   ('tyrion-kills-tywin','tywin-lannister','victim',NULL),
   ('tyrion-kills-tywin','tyrion-lannister','instigator',NULL),
   ('kevan-assassinated','kevan-lannister','victim',NULL),
   ('sack-of-kings-landing','tywin-lannister','instigator',NULL),
   ('sack-of-kings-landing','jaime-lannister','instigator','Killed Aerys II as the city fell.')
)
INSERT INTO event_participant (event_id, member_id, role, notes)
SELECT ev.id, m.id, ep.role, ep.notes
FROM ep JOIN event ev ON ev.slug=ep.event_slug JOIN member m ON m.slug=ep.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM event_participant x WHERE x.event_id=ev.id AND x.member_id=m.id
);

WITH wh(war_slug, house_slug, side, role, outcome) AS (
  VALUES
   ('aegons-conquest','lannister','two-kings','defender','Submitted after the Field of Fire.'),
   ('dance-of-the-dragons','lannister','greens','ally','Jason died and the western host was broken.'),
   ('first-blackfyre-rebellion','lannister','loyalists','ally','Damon remained loyal to Daeron II.'),
   ('war-of-ninepenny-kings','lannister','iron-throne','ally','Westermen fought in the Stepstones under Jason Lannister.'),
   ('reyne-tarbeck-revolt','lannister','lannister','commander','Tywin extinguished the rebel vassals.'),
   ('roberts-rebellion','lannister','rebels','ally','Tywin joined late and sacked King''s Landing.'),
   ('greyjoy-rebellion','lannister','iron-throne','ally','Lannister forces served the royal response.'),
   ('war-of-the-five-kings','lannister','joffrey-tommen','commander','House Lannister defended the royal claim of Joffrey and Tommen.')
)
INSERT INTO war_participant (war_id, house_id, side, role, outcome)
SELECT w.id, h.id, wh.side, wh.role, wh.outcome
FROM wh JOIN war w ON w.slug=wh.war_slug JOIN house h ON h.slug=wh.house_slug
WHERE NOT EXISTS (
  SELECT 1 FROM war_participant x WHERE x.war_id=w.id AND x.house_id=h.id AND x.side=wh.side
);

WITH wm(war_slug, member_slug, side, role, outcome) AS (
  VALUES
   ('aegons-conquest','loren-i-lannister','two-kings','commander','Submitted after defeat.'),
   ('dance-of-the-dragons','jason-lannister-dance','greens','commander','Slain at the Red Fork.'),
   ('dance-of-the-dragons','tyland-lannister','greens','ally','Guarded the royal treasury and survived torture.'),
   ('first-blackfyre-rebellion','damon-lannister-grey-lion','loyalists','commander','Defeated outside Lannisport but remained loyal.'),
   ('war-of-ninepenny-kings','jason-lannister-son-of-gerold','iron-throne','commander',NULL),
   ('war-of-ninepenny-kings','tywin-lannister','iron-throne','combatant',NULL),
   ('war-of-ninepenny-kings','kevan-lannister','iron-throne','combatant',NULL),
   ('war-of-ninepenny-kings','tygett-lannister','iron-throne','combatant',NULL),
   ('reyne-tarbeck-revolt','tywin-lannister','lannister','commander','Destroyed Houses Reyne and Tarbeck.'),
   ('roberts-rebellion','tywin-lannister','rebels','commander','Sacked King''s Landing.'),
   ('roberts-rebellion','jaime-lannister','rebels','combatant','Killed Aerys II.'),
   ('war-of-the-five-kings','tywin-lannister','joffrey-tommen','commander',NULL),
   ('war-of-the-five-kings','jaime-lannister','joffrey-tommen','commander','Captured by Robb Stark, later freed.'),
   ('war-of-the-five-kings','tyrion-lannister','joffrey-tommen','commander','Led the defense of King''s Landing as acting Hand.'),
   ('war-of-the-five-kings','cersei-lannister','joffrey-tommen','commander','Queen Regent for Joffrey and Tommen.'),
   ('war-of-the-five-kings','kevan-lannister','joffrey-tommen','ally',NULL),
   ('war-of-the-five-kings','stafford-lannister','joffrey-tommen','commander','Slain at Oxcross.'),
   ('war-of-the-five-kings','daven-lannister','joffrey-tommen','commander',NULL)
)
INSERT INTO war_participant (war_id, member_id, side, role, outcome)
SELECT w.id, m.id, wm.side, wm.role, wm.outcome
FROM wm JOIN war w ON w.slug=wm.war_slug JOIN member m ON m.slug=wm.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM war_participant x WHERE x.war_id=w.id AND x.member_id=m.id
);

WITH bp(battle_slug, member_slug, house_slug, side, role, commander, killed) AS (
  VALUES
   ('field-of-fire','loren-i-lannister','lannister','two-kings','commander',1,0),
   ('battle-of-the-red-fork','jason-lannister-dance','lannister','greens','commander',1,1),
   ('battle-by-the-lakeshore',NULL,'lannister','greens','combatant',0,0),
   ('battle-of-fair-isle','erwin-lannister','lannister','lannister','commander',1,1),
   ('battle-of-wendwater-bridge','tywald-lannister','lannister','loyalists','combatant',0,1),
   ('battle-of-wendwater-bridge','tion-lannister-son-of-gerold','lannister','loyalists','combatant',0,1),
   ('fall-of-tarbeck-hall','tywin-lannister','lannister','lannister','commander',1,0),
   ('fall-of-castamere','tywin-lannister','lannister','lannister','commander',1,0),
   ('sack-of-kings-landing','tywin-lannister','lannister','rebels','commander',1,0),
   ('sack-of-kings-landing','jaime-lannister','lannister','rebels','combatant',0,0),
   ('battle-of-oxcross','stafford-lannister','lannister','lannister','commander',1,1),
   ('battle-of-the-blackwater','tyrion-lannister','lannister','joffrey-tommen','commander',1,0),
   ('battle-of-the-blackwater','tywin-lannister','lannister','joffrey-tommen','commander',1,0)
)
INSERT INTO battle_participant (battle_id, member_id, house_id, side, role, was_commander, was_killed)
SELECT b.id, m.id, h.id, bp.side, bp.role, bp.commander, bp.killed
FROM bp
JOIN battle b ON b.slug=bp.battle_slug
LEFT JOIN member m ON m.slug=bp.member_slug
LEFT JOIN house h ON h.slug=bp.house_slug
WHERE NOT EXISTS (
  SELECT 1 FROM battle_participant x
  WHERE x.battle_id=b.id
    AND COALESCE(x.member_id,-1)=COALESCE(m.id,-1)
    AND COALESCE(x.house_id,-1)=COALESCE(h.id,-1)
    AND x.side=bp.side
);
