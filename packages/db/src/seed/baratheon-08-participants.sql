-- Baratheon participants.

WITH ep(event_slug, member_slug, role, notes) AS (
  VALUES
   ('founding-of-house-baratheon','orys-baratheon','subject',NULL),
   ('founding-of-house-baratheon','argella-durrandon','subject',NULL),
   ('steffon-and-cassana-drown','steffon-baratheon','victim',NULL),
   ('steffon-and-cassana-drown','cassana-estermont','victim',NULL),
   ('robert-crowned','robert-baratheon','subject',NULL),
   ('robert-dies','robert-baratheon','victim',NULL),
   ('renly-murdered','renly-baratheon','victim',NULL)
)
INSERT INTO event_participant (event_id, member_id, role, notes)
SELECT ev.id, m.id, ep.role, ep.notes
FROM ep JOIN event ev ON ev.slug=ep.event_slug JOIN member m ON m.slug=ep.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM event_participant x WHERE x.event_id=ev.id AND x.member_id=m.id
);

WITH wp(war_slug, member_slug, side, role, outcome) AS (
  VALUES
   ('aegons-conquest','orys-baratheon','targaryen','commander','Founded House Baratheon.'),
   ('aegons-conquest','argilac-durrandon','storm-kings','defender','Slain in battle.'),
   ('laughing-storm-rebellion','lyonel-baratheon','baratheon','commander','Reconciled after trial of seven.'),
   ('war-of-ninepenny-kings','ormund-baratheon','iron-throne','commander','Slain in the Stepstones.'),
   ('roberts-rebellion','robert-baratheon','rebels','commander','Crowned king.'),
   ('roberts-rebellion','stannis-baratheon','rebels','defender','Held Storm''s End.'),
   ('war-of-the-five-kings','stannis-baratheon','stannis','commander',NULL),
   ('war-of-the-five-kings','renly-baratheon','renly','commander','Murdered before battle.')
)
INSERT INTO war_participant (war_id, member_id, side, role, outcome)
SELECT w.id, m.id, wp.side, wp.role, wp.outcome
FROM wp JOIN war w ON w.slug=wp.war_slug JOIN member m ON m.slug=wp.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM war_participant x WHERE x.war_id=w.id AND x.member_id=m.id
);

WITH bp(battle_slug, member_slug, house_slug, side, role, commander, killed) AS (
  VALUES
   ('last-storm','orys-baratheon','baratheon','targaryen','commander',1,0),
   ('last-storm','argilac-durrandon',NULL,'storm-kings','commander',1,1),
   ('battle-of-summerhall','robert-baratheon','baratheon','rebels','commander',1,0),
   ('battle-of-ashford','robert-baratheon','baratheon','rebels','commander',1,0),
   ('siege-of-storms-end','stannis-baratheon','baratheon','rebels','commander',1,0),
   ('battle-of-the-trident','robert-baratheon','baratheon','rebels','commander',1,0),
   ('battle-of-the-blackwater','stannis-baratheon','baratheon','stannis','commander',1,0)
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
