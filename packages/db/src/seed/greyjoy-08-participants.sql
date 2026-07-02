-- Greyjoy participants.

WITH ep(event_slug, member_slug, role, notes) AS (
  VALUES
   ('vickon-chosen','vickon-greyjoy','beneficiary',NULL),
   ('dalton-murdered','dalton-greyjoy','victim',NULL),
   ('theon-taken-ward','theon-greyjoy','subject',NULL),
   ('theon-taken-ward','ned-stark','guardian',NULL),
   ('balon-crowned-again','balon-greyjoy','subject',NULL),
   ('kingsmoot-of-old-wyk','euron-greyjoy','beneficiary',NULL),
   ('kingsmoot-of-old-wyk','asha-greyjoy','other','Failed claimant.'),
   ('kingsmoot-of-old-wyk','victarion-greyjoy','other','Failed claimant.')
)
INSERT INTO event_participant (event_id, member_id, role, notes)
SELECT ev.id, m.id, ep.role, ep.notes
FROM ep JOIN event ev ON ev.slug=ep.event_slug JOIN member m ON m.slug=ep.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM event_participant x WHERE x.event_id=ev.id AND x.member_id=m.id
);

WITH wp(war_slug, member_slug, side, role, outcome) AS (
  VALUES
   ('aegons-conquest','vickon-greyjoy','ironborn','beneficiary','Chosen by the ironborn.'),
   ('dance-of-the-dragons','dalton-greyjoy','blacks','ally','Raided the westerlands.'),
   ('greyjoy-rebellion','balon-greyjoy','ironborn','commander','Defeated.'),
   ('greyjoy-rebellion','victarion-greyjoy','ironborn','commander','Iron Fleet destroyed.'),
   ('greyjoy-rebellion','robert-baratheon','royalists','commander','Crushed the rebellion.'),
   ('greyjoy-rebellion','stannis-baratheon','royalists','commander','Destroyed the Iron Fleet.'),
   ('war-of-the-five-kings','balon-greyjoy','ironborn','commander','Crowned himself.'),
   ('war-of-the-five-kings','asha-greyjoy','ironborn','commander',NULL),
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
   ('battle-of-fair-isle','dalton-greyjoy','greyjoy','ironborn','commander',1,0),
   ('battle-off-fair-isle','victarion-greyjoy','greyjoy','ironborn','commander',1,0),
   ('battle-off-fair-isle','stannis-baratheon','baratheon','royalists','commander',1,0),
   ('siege-of-pyke','balon-greyjoy','greyjoy','ironborn','commander',1,0),
   ('siege-of-pyke','robert-baratheon','baratheon','royalists','commander',1,0),
   ('siege-of-pyke','ned-stark','stark','royalists','commander',0,0),
   ('siege-of-pyke','maron-greyjoy','greyjoy','ironborn','combatant',0,1),
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
