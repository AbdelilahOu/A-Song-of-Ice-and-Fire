-- Stark participants.

WITH ep(event_slug, member_slug, role, notes) AS (
  VALUES
   ('founding-of-winterfell','brandon-the-builder','subject',NULL),
   ('torrhen-stark-kneels','torrhen-stark','subject',NULL),
   ('rickard-and-brandon-executed','rickard-stark','victim',NULL),
   ('rickard-and-brandon-executed','brandon-stark-son-of-rickard','victim',NULL),
   ('lyanna-dies','lyanna-stark','victim',NULL),
   ('lyanna-dies','jon-snow','subject',NULL),
   ('robb-crowned','robb-stark','subject',NULL),
   ('red-wedding-event','robb-stark','victim',NULL),
   ('red-wedding-event','catelyn-tully','victim',NULL)
)
INSERT INTO event_participant (event_id, member_id, role, notes)
SELECT ev.id, m.id, ep.role, ep.notes
FROM ep JOIN event ev ON ev.slug=ep.event_slug JOIN member m ON m.slug=ep.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM event_participant x WHERE x.event_id=ev.id AND x.member_id=m.id
);

WITH wp(war_slug, member_slug, side, role, outcome) AS (
  VALUES
   ('aegons-conquest','torrhen-stark','north','commander','Submitted peacefully.'),
   ('dance-of-the-dragons','cregan-stark','blacks','commander','Served briefly as Hand.'),
   ('roberts-rebellion','ned-stark','rebels','commander','Helped overthrow Aerys II.'),
   ('roberts-rebellion','rickard-stark','rebels','victim','Executed before the war.'),
   ('greyjoy-rebellion','ned-stark','royalists','commander','Helped storm Pyke.'),
   ('war-of-the-five-kings','robb-stark','stark-tully','commander','Murdered at the Red Wedding.'),
   ('war-of-the-five-kings','catelyn-tully','stark-tully','ally','Murdered at the Red Wedding.'),
   ('war-of-the-five-kings','theon-greyjoy','ironborn','commander','Captured Winterfell.')
)
INSERT INTO war_participant (war_id, member_id, side, role, outcome)
SELECT w.id, m.id, wp.side, wp.role, wp.outcome
FROM wp JOIN war w ON w.slug=wp.war_slug JOIN member m ON m.slug=wp.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM war_participant x WHERE x.war_id=w.id AND x.member_id=m.id
);

WITH bp(battle_slug, member_slug, house_slug, side, role, commander, killed) AS (
  VALUES
   ('torrhen-kneels','torrhen-stark','stark','north','commander',1,0),
   ('hour-of-the-wolf','cregan-stark','stark','blacks','commander',1,0),
   ('tower-of-joy','ned-stark','stark','rebels','commander',1,0),
   ('siege-of-pyke','ned-stark','stark','royalists','commander',0,0),
   ('battle-of-the-whispering-wood','robb-stark','stark','stark-tully','commander',1,0),
   ('battle-of-the-camps','robb-stark','stark','stark-tully','commander',1,0),
   ('red-wedding','robb-stark','stark','stark-tully','commander',1,1),
   ('red-wedding','catelyn-tully','tully','stark-tully','combatant',0,1),
   ('capture-of-winterfell','theon-greyjoy','greyjoy','ironborn','commander',1,0)
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
