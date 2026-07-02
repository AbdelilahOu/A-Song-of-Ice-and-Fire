-- Tully participants.

WITH ep(event_slug, member_slug, role, notes) AS (
  VALUES
   ('tully-paramountcy','edmure-tully-ancestor','beneficiary',NULL),
   ('hoster-tully-dies','hoster-tully','victim',NULL),
   ('red-wedding-event','catelyn-tully','victim',NULL),
   ('red-wedding-event','robb-stark','victim',NULL),
   ('red-wedding-event','edmure-tully','subject','His wedding was used as the trap.'),
   ('red-wedding-event','walder-frey','instigator',NULL),
   ('lysa-falls','lysa-tully','victim',NULL),
   ('lysa-falls','petyr-baelish','instigator',NULL)
)
INSERT INTO event_participant (event_id, member_id, role, notes)
SELECT ev.id, m.id, ep.role, ep.notes
FROM ep JOIN event ev ON ev.slug=ep.event_slug JOIN member m ON m.slug=ep.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM event_participant x WHERE x.event_id=ev.id AND x.member_id=m.id
);

WITH wp(war_slug, member_slug, side, role, outcome) AS (
  VALUES
   ('aegons-conquest','edmure-tully-ancestor','targaryen','ally','Raised to paramountcy.'),
   ('dance-of-the-dragons','kermit-tully','blacks','commander','Helped end the war.'),
   ('dance-of-the-dragons','oscar-tully','blacks','commander',NULL),
   ('roberts-rebellion','hoster-tully','rebels','ally','Joined by marriage pact.'),
   ('war-of-the-five-kings','catelyn-tully','stark-tully','ally',NULL),
   ('war-of-the-five-kings','edmure-tully','stark-tully','commander','Captured after the Red Wedding.'),
   ('war-of-the-five-kings','brynden-tully','stark-tully','commander','Held Riverrun after the Red Wedding.')
)
INSERT INTO war_participant (war_id, member_id, side, role, outcome)
SELECT w.id, m.id, wp.side, wp.role, wp.outcome
FROM wp JOIN war w ON w.slug=wp.war_slug JOIN member m ON m.slug=wp.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM war_participant x WHERE x.war_id=w.id AND x.member_id=m.id
);

WITH bp(battle_slug, member_slug, house_slug, side, role, commander, killed) AS (
  VALUES
   ('burning-of-harrenhal','edmure-tully-ancestor','tully','targaryen','ally',0,0),
   ('battle-of-the-kingsroad','kermit-tully','tully','blacks','commander',1,0),
   ('battle-of-the-kingsroad','oscar-tully','tully','blacks','commander',0,0),
   ('battle-of-the-camps','edmure-tully','tully','stark-tully','commander',1,0),
   ('red-wedding','catelyn-tully','tully','stark-tully','combatant',0,1),
   ('red-wedding','robb-stark','stark','stark-tully','commander',1,1),
   ('second-siege-of-riverrun','brynden-tully','tully','tully','commander',1,0),
   ('second-siege-of-riverrun','edmure-tully','tully','tully','combatant',0,0)
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
