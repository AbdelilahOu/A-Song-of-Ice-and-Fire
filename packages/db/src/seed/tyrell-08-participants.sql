-- Tyrell participants.

WITH ep(event_slug, member_slug, role, notes) AS (
  VALUES
   ('tyrells-raised-to-highgarden','harlen-tyrell','beneficiary',NULL),
   ('renly-marries-margaery','renly-baratheon','subject',NULL),
   ('renly-marries-margaery','margaery-tyrell','subject',NULL),
   ('tyrell-lannister-alliance','mace-tyrell','instigator',NULL),
   ('tyrell-lannister-alliance','loras-tyrell','other','Wore Renly''s armor during the relief of King''s Landing.'),
   ('joffreys-wedding-poisoning','margaery-tyrell','witness',NULL),
   ('joffreys-wedding-poisoning','olenna-redwyne','instigator','Widely implicated in arranging the poisoning.')
)
INSERT INTO event_participant (event_id, member_id, role, notes)
SELECT ev.id, m.id, ep.role, ep.notes
FROM ep JOIN event ev ON ev.slug=ep.event_slug JOIN member m ON m.slug=ep.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM event_participant x WHERE x.event_id=ev.id AND x.member_id=m.id
);

WITH wp(war_slug, member_slug, side, role, outcome) AS (
  VALUES
   ('aegons-conquest','harlen-tyrell','targaryen','beneficiary','Raised to Highgarden.'),
   ('dance-of-the-dragons','theo-tyrell','neutral','ally','The Reach remained divided.'),
   ('roberts-rebellion','mace-tyrell','loyalists','commander','Besieged Storm''s End.'),
   ('war-of-the-five-kings','mace-tyrell','renly-then-joffrey','commander','Joined the Lannister regime.'),
   ('war-of-the-five-kings','loras-tyrell','renly-then-joffrey','combatant',NULL),
   ('war-of-the-five-kings','margaery-tyrell','renly-then-joffrey','ally',NULL)
)
INSERT INTO war_participant (war_id, member_id, side, role, outcome)
SELECT w.id, m.id, wp.side, wp.role, wp.outcome
FROM wp JOIN war w ON w.slug=wp.war_slug JOIN member m ON m.slug=wp.member_slug
WHERE NOT EXISTS (
  SELECT 1 FROM war_participant x WHERE x.war_id=w.id AND x.member_id=m.id
);

WITH bp(battle_slug, member_slug, house_slug, side, role, commander, killed) AS (
  VALUES
   ('field-of-fire','harlen-tyrell','tyrell','targaryen','ally',0,0),
   ('siege-of-storms-end','mace-tyrell','tyrell','loyalists','commander',1,0),
   ('battle-of-ashford','randyll-tarly',NULL,'loyalists','commander',1,0),
   ('battle-of-the-blackwater','mace-tyrell','tyrell','joffrey-tommen','commander',1,0),
   ('battle-of-the-blackwater','loras-tyrell','tyrell','joffrey-tommen','combatant',0,0)
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
