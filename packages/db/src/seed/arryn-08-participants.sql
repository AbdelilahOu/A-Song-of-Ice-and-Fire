-- Arryn participants.

WITH ep(event_slug, member_slug, role, notes) AS (
  VALUES
   ('founding-of-house-arryn','artys-arryn','subject',NULL),
   ('visenya-at-the-eyrie','ronnel-arryn','subject',NULL),
   ('visenya-at-the-eyrie','sharra-arryn','subject',NULL),
   ('jon-arryn-calls-banners','jon-arryn','instigator',NULL),
   ('jon-arryn-poisoned','jon-arryn','victim',NULL),
   ('jon-arryn-poisoned','lysa-tully','instigator',NULL),
   ('lysa-through-moon-door','lysa-tully','victim',NULL),
   ('lysa-through-moon-door','petyr-baelish','instigator',NULL)
)
INSERT INTO event_participant (event_id, member_id, role, notes)
SELECT ev.id, m.id, ep.role, ep.notes
FROM ep JOIN event ev ON ev.slug=ep.event_slug JOIN member m ON m.slug=ep.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM event_participant x WHERE x.event_id=ev.id AND x.member_id=m.id
);

WITH wp(war_slug, member_slug, side, role, outcome) AS (
  VALUES
   ('andal-conquest-of-the-vale','artys-arryn','andals','commander','Founded House Arryn.'),
   ('andal-conquest-of-the-vale','robar-ii-royce','first-men','defender','Defeated.'),
   ('aegons-conquest','ronnel-arryn','vale','defender','Submitted peacefully.'),
   ('dance-of-the-dragons','jeyne-arryn','blacks','ally','Supported Rhaenyra.'),
   ('roberts-rebellion','jon-arryn','rebels','commander','Helped begin and win the rebellion.')
)
INSERT INTO war_participant (war_id, member_id, side, role, outcome)
SELECT w.id, m.id, wp.side, wp.role, wp.outcome
FROM wp JOIN war w ON w.slug=wp.war_slug JOIN member m ON m.slug=wp.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM war_participant x WHERE x.war_id=w.id AND x.member_id=m.id
);

WITH bp(battle_slug, member_slug, house_slug, side, role, commander, killed) AS (
  VALUES
   ('battle-of-the-seven-stars','artys-arryn','arryn','andals','commander',1,0),
   ('battle-of-the-seven-stars','robar-ii-royce',NULL,'first-men','commander',1,0),
   ('battle-of-gulltown','jon-arryn','arryn','rebels','commander',1,0),
   ('battle-of-the-bells','jon-arryn','arryn','rebels','commander',1,0)
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
