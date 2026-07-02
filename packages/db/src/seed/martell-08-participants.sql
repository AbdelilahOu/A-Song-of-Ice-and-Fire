-- Martell participants.

WITH ep(event_slug, member_slug, role, notes) AS (
  VALUES
   ('nymeria-burns-ships','nymeria','subject',NULL),
   ('nymeria-burns-ships','mors-martell','beneficiary',NULL),
   ('dorne-joins-realm','maron-martell','subject',NULL),
   ('dorne-joins-realm','daenerys-targaryen-princess','subject',NULL),
   ('elia-and-children-murdered','elia-martell','victim',NULL),
   ('elia-and-children-murdered','rhaenys-targaryen-younger','victim',NULL),
   ('elia-and-children-murdered','aegon-targaryen-son','victim',NULL),
   ('oberyn-trial-by-combat','oberyn-martell','victim',NULL),
   ('quentyn-burned','quentyn-martell','victim',NULL)
)
INSERT INTO event_participant (event_id, member_id, role, notes)
SELECT ev.id, m.id, ep.role, ep.notes
FROM ep JOIN event ev ON ev.slug=ep.event_slug JOIN member m ON m.slug=ep.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM event_participant x WHERE x.event_id=ev.id AND x.member_id=m.id
);

WITH wp(war_slug, member_slug, side, role, outcome) AS (
  VALUES
   ('nymerias-war','nymeria','martell-rhoynar','commander','Unified Dorne.'),
   ('nymerias-war','mors-martell','martell-rhoynar','commander','Unified Dorne.'),
   ('first-dornish-war','meria-martell','dorne','commander','Preserved independence.'),
   ('daerons-conquest-of-dorne','mara-martell','dorne','ally',NULL),
   ('roberts-rebellion','lewyn-martell','loyalists','combatant','Slain at the Trident.'),
   ('roberts-rebellion','elia-martell','loyalists','victim','Murdered in King''s Landing.'),
   ('war-of-the-five-kings','doran-martell','dorne','ally','Stayed formally aligned through Myrcella.')
)
INSERT INTO war_participant (war_id, member_id, side, role, outcome)
SELECT w.id, m.id, wp.side, wp.role, wp.outcome
FROM wp JOIN war w ON w.slug=wp.war_slug JOIN member m ON m.slug=wp.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM war_participant x WHERE x.war_id=w.id AND x.member_id=m.id
);

WITH bp(battle_slug, member_slug, house_slug, side, role, commander, killed) AS (
  VALUES
   ('rhaenys-at-the-hellholt','meria-martell','martell','dorne','commander',1,0),
   ('battle-of-the-trident','lewyn-martell','martell','loyalists','combatant',0,1),
   ('sack-of-kings-landing','elia-martell','martell','loyalists','combatant',0,1)
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
