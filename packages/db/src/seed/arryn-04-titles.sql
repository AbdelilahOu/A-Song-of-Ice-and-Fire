-- Arryn titles and relations.

WITH t(slug, title, sy, ey, current_flag) AS (
  VALUES
   ('artys-arryn','King of Mountain and Vale',NULL,NULL,0),
   ('ronnel-arryn','King of Mountain and Vale',NULL,1,0),
   ('ronnel-arryn','Lord of the Eyrie',1,NULL,0),
   ('sharra-arryn','Queen Regent of Mountain and Vale',NULL,1,0),
   ('jeyne-arryn','Lady of the Eyrie',97,134,0),
   ('jeyne-arryn','Warden of the East',97,134,0),
   ('jon-arryn','Lord of the Eyrie',NULL,298,0),
   ('jon-arryn','Warden of the East',NULL,298,0),
   ('jon-arryn','Hand of the King',283,298,0),
   ('robert-arryn','Lord of the Eyrie',298,NULL,1),
   ('robert-arryn','Defender of the Vale',298,NULL,1),
   ('petyr-baelish','Lord Protector of the Vale',300,NULL,1),
   ('harrold-hardyng','Heir Presumptive to the Eyrie',300,NULL,1)
)
INSERT INTO member_title (member_id, title, start_year, end_year, is_current)
SELECT m.id, t.title, t.sy, t.ey, t.current_flag
FROM t JOIN member m ON m.slug=t.slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_title mt
  WHERE mt.member_id=m.id AND mt.title=t.title AND COALESCE(mt.start_year,-99999)=COALESCE(t.sy,-99999)
);

WITH r(from_slug, to_slug, type, notes) AS (
  VALUES
   ('jon-arryn','robert-baratheon','guardian','Jon fostered Robert Baratheon at the Eyrie.'),
   ('jon-arryn','ned-stark','guardian','Jon fostered Eddard Stark at the Eyrie.'),
   ('robert-baratheon','ned-stark','fostered_by','Robert and Eddard formed their bond as wards of Jon Arryn.'),
   ('lysa-tully','petyr-baelish','paramour','Lysa loved Petyr Baelish and poisoned Jon Arryn at his urging.')
)
INSERT INTO member_relation (from_member_id, to_member_id, type, notes)
SELECT f.id, tt.id, r.type, r.notes
FROM r JOIN member f ON f.slug=r.from_slug JOIN member tt ON tt.slug=r.to_slug
WHERE NOT EXISTS (
  SELECT 1 FROM member_relation mr
  WHERE mr.from_member_id=f.id AND mr.to_member_id=tt.id AND mr.type=r.type
);
