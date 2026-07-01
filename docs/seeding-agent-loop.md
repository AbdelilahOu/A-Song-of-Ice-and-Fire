# Westeros Lineages — Seeding Agent Loop

Standing instructions for an external AI agent (Manus) that connects to the
project's MCP server and keeps generating images and seeding data until the app
has the full dataset. Run these instructions on a loop: each pass, re-read the
current state, fill the next gap, verify, and repeat. Stop when the completion
checklist at the bottom is fully satisfied.

## Mission

Populate the Westeros Lineages database with a complete, canonically accurate
dataset for the nine Great Houses of A Song of Ice and Fire / Game of Thrones:
houses (with banner + frame images), their members and lineages, marriages,
titles, allegiances, deaths, the relations between houses, the major wars and
battles, key locations, dragons, and timeline events.

Accuracy matters. Before writing a house, member, war, or death, do a web search
to confirm names, years, parentage, and outcomes against the books and
A Wiki of Ice and Fire. Do not invent facts.

## Connection

- MCP endpoint: `https://api.westeros.ar7al.dev/mcp`
- Transport: Streamable HTTP
- Auth: none (open, development server)
- Assets are served from `https://assets.westeros.ar7al.dev/<key>`. The
  `upload_asset` tool returns the final public URL; store that URL verbatim in
  the matching `*Path` field.

## Golden rules

1. **Idempotent — safe to re-run.** `insert_*` upserts by slug (creates or
   updates). `add_*` link tools deduplicate. Re-running any call is safe, so the
   loop can always resume without creating duplicates.
2. **Create referenced records first.** Relations are resolved by slug and the
   tool errors if the target does not exist yet. Order every pass so parents
   exist before children, houses before members, locations/wars before the
   battles and deaths that reference them.
3. **Slugs are kebab-case and stable.** `stark`, `eddard-stark`, `winterfell`,
   `roberts-rebellion`, `battle-of-the-trident`. Reuse the same slug everywhere
   you reference an entity.
4. **Years use the Aegon's Conquest epoch.** Integer; negative is BC (Before
   Conquest), positive is AC. Robert's Rebellion is 282–283 AC.
5. **Verify after writing.** Use `get_house`, `get_member`, `list_members`,
   `list_houses`, and `list_assets` to confirm each batch landed before moving
   on.

## Tool reference

Reads (use to decide what is missing):
- `list_houses` — all houses with slug/name/region/status.
- `get_house { slug }` — one house's full row (or null).
- `list_members { houseSlug?, limit? }` — members, optionally filtered to a house.
- `get_member { slug }` — one member's full row (or null).
- `list_assets { prefix?, cursor?, limit? }`, `get_asset_metadata { key }`.

Houses:
- `insert_house { slug, name, fullName?, words?, region?, seat?,
  sigilDescription?, sigilColors?, foundedYear?, founderSlug?, currentLordSlug?,
  status?, isGreatHouse?, summary?, history?, bannerPath?, framePath? }`
- `link_houses { houseASlug, houseBSlug, type, startYear?, endYear?, isCurrent?,
  description? }` — type: alliance | rivalry | feud | war | vassalage |
  cadet_branch | marriage_pact (pair is unordered; for vassalage/cadet_branch,
  houseA is the subordinate).

Members:
- `insert_member { slug, name, fullName?, surname?, epithet?, houseSlug?,
  fatherSlug?, motherSlug?, gender?, status?, isBastard?, isLegitimized?,
  bornYear?, diedYear?, culture?, portraitPath?, bio?, notableFor? }`
  — gender: male | female | unknown; status: alive | dead | unknown.
- `add_title { memberSlug, title, startYear?, endYear?, isCurrent? }`
- `add_marriage { spouseASlug, spouseBSlug, status?, startYear?, endYear?,
  isSecret?, notes? }` — status: married | widowed | annulled | separated |
  betrothed.
- `add_member_relation { fromSlug, toSlug, type, notes? }` — type: sibling |
  half_sibling | twin | guardian | ward | fostered_by | paramour | betrothed |
  sworn_sword | heir_of | other. (Lineage parent links live on the member row
  via fatherSlug/motherSlug — do not use this for parent/child.)
- `add_allegiance { memberSlug, houseSlug, role?, isCurrent?, startYear?,
  endYear?, notes? }` — role: lord | lady | heir | member | bannerman |
  sworn_sword | household | ward | married_in.
- `record_death { memberSlug, year?, locationSlug?, cause?, killerSlug?,
  battleSlug?, description?, isConfirmed? }`

Locations:
- `insert_location { slug, name, type?, region?, controllingHouseSlug?,
  description? }` — type: castle | stronghold | city | town | region | island |
  ruin | landmark | other.

Conflicts:
- `insert_war { slug, name, startYear?, endYear?, description?, outcome?,
  victorHouseSlug? }`
- `insert_battle { slug, name, warSlug?, year?, locationSlug?, description?,
  outcome?, victorSide? }`
- `add_war_participant { warSlug, houseSlug?, memberSlug?, side?, role?,
  outcome? }` — role: attacker | defender | instigator | ally | commander |
  combatant. Provide at least a house or a member.
- `add_battle_participant { battleSlug, houseSlug?, memberSlug?, side?, role?,
  wasCommander?, wasKilled? }`

Dragons:
- `insert_dragon { slug, name, status?, size?, color?, bornYear?, diedYear?,
  notableRiderSlug?, killedInBattleSlug?, description?, fate? }` — status: alive
  | dead | unknown | wild; size: hatchling | small | medium | large | great |
  unknown.
- `add_dragon_rider { dragonSlug, memberSlug, startYear?, endYear?, isNotable?,
  notes? }`

Events:
- `insert_event { slug, name, type?, year?, endYear?, locationSlug?, warSlug?,
  battleSlug?, description? }` — type: birth | death | marriage | battle | war |
  coronation | alliance | betrayal | dragon_hatching | founding | other.
- `add_event_participant { eventSlug, memberSlug?, houseSlug?, role?, notes? }`
  — role: subject | witness | instigator | victim | beneficiary | other.

Assets:
- `upload_asset { key, contentBase64, contentType }` — returns
  `{ key, contentType, size, url }`. Store `url` in the `*Path` field.
- `list_assets`, `get_asset_metadata`, `delete_asset { key }`.

Asset key convention:
- House banner: `houses/<slug>/banner.webp` -> house `bannerPath`
- House frame: `houses/<slug>/frame.webp` -> house `framePath`
- Member portrait: `members/<slug>/portrait.webp` -> member `portraitPath`

## Image generation

Generate images, then upload them with `upload_asset` and store the returned URL
on the record. Always web-search the real heraldry first so the output matches
canon. Prefer WebP; `contentType` is `image/webp`.

### Banner prompt (per house)

> Web-search "House {Name} sigil A Song of Ice and Fire" to confirm the exact
> device and tinctures. Create a tall vertical house banner, 2:3 aspect ratio
> (1536x2304). Show {sigil: e.g. "a grey direwolf running"} centered on a
> {field color} field, rendered as a weathered cloth tapestry with subtle folds,
> dramatic rim lighting, and a dark vignette. Heraldic, cinematic, museum
> quality. No text, no letters, no watermark. Export as WebP.

### Frame prompt (per house)

> Create an ornate portrait frame for House {Name}, 3:4 aspect ratio
> (1632x2176), RGBA with a FULLY TRANSPARENT center window: the inner ~72% must
> be empty (alpha 0) so a portrait shows through — only the outer border is
> opaque. The border is carved metal-and-wood ornamentation themed to the house
> ({motifs + colors, e.g. "direwolves, frost, cold silver and slate grey" for
> Stark}). Symmetrical, medieval, elegant, high detail. Preserve alpha. Export
> as WebP (or PNG) with transparency.

### Portrait prompt (per member, optional polish)

> Web-search "{full name} Game of Thrones" for appearance. Create a painterly
> head-and-shoulders character portrait, 3:4 aspect (900x1200), on a neutral
> dark background, consistent with the books/show, cinematic cold medieval
> lighting. No text, no border, no frame. Export as WebP.

## The nine Great Houses (reference baseline — verify by search)

| slug | name | words | seat | region | sigil colors |
| --- | --- | --- | --- | --- | --- |
| stark | Stark | Winter Is Coming | Winterfell | The North | grey, white |
| lannister | Lannister | Hear Me Roar | Casterly Rock | The Westerlands | gold, crimson |
| targaryen | Targaryen | Fire and Blood | Dragonstone | The Crownlands | red, black |
| baratheon | Baratheon | Ours Is the Fury | Storm's End | The Stormlands | black, gold |
| tully | Tully | Family, Duty, Honor | Riverrun | The Riverlands | red, blue, silver |
| arryn | Arryn | As High as Honor | The Eyrie | The Vale | sky blue, white, cream |
| tyrell | Tyrell | Growing Strong | Highgarden | The Reach | green, gold |
| martell | Martell | Unbowed, Unbent, Unbroken | Sunspear | Dorne | orange, red, gold |
| greyjoy | Greyjoy | We Do Not Sow | Pyke | The Iron Islands | gold, black |

## The loop

Each iteration, do the following. Perform exactly one unit of useful work per
pass (one house set up, or one house's members, or one war and its battles) so
progress is checkpointed and resumable.

1. **Assess.** Call `list_houses`. For each of the nine great houses, decide its
   state: missing, present-but-imageless, or present-with-members. Call
   `list_members { houseSlug }` to see who exists.

2. **Pick the next gap** in this priority order:
   - Phase 1 — Houses + seats: any of the nine missing, or missing
     banner/frame. Generate banner and frame, `upload_asset` both, then
     `insert_house` with `bannerPath`/`framePath` set, `isGreatHouse: true`, and
     `insert_location` for its seat (`controllingHouseSlug` = the house).
   - Phase 2 — Members + lineage: a house with no/few members. Web-search its
     canonical lineage. `insert_member` oldest-to-youngest (so `fatherSlug` /
     `motherSlug` already exist), then `add_title`, `add_allegiance`.
   - Phase 3 — Marriages + relations: `add_marriage` (including cross-house),
     `add_member_relation` for siblings, wards, sworn swords, paramours.
   - Phase 4 — House relations: `link_houses` for alliances, rivalries,
     vassalage, marriage pacts.
   - Phase 5 — Wars + battles + deaths + events: `insert_war`, then
     `insert_battle` (with `warSlug`/`locationSlug`), then
     `add_war_participant` / `add_battle_participant`, then `record_death` for
     those who died, then `insert_event` + `add_event_participant` for key
     moments.
   - Phase 6 — Dragons (Targaryen focus): `insert_dragon`, `add_dragon_rider`.
   - Phase 7 — Portraits (polish): generate and upload member portraits, then
     `insert_member` again with `portraitPath` set (upsert updates in place).

3. **Do the work** for that one gap, respecting the dependency order within it.

4. **Verify.** Re-read with `get_house` / `get_member` / `list_members` /
   `list_assets`. If a call errored because a referenced slug was missing, create
   that dependency first and retry.

5. **Repeat.** Continue until the completion checklist passes, then stop.

Suggested seeding order across houses: start with Stark (reference lineage is
richest and already partly known), then Targaryen (needed for dragons and the
Conquest), then Lannister, Baratheon, Tully, Arryn, Tyrell, Martell, Greyjoy.

## Canonical anchors to cover (not exhaustive — expand via search)

- Wars: Aegon's Conquest, the Dance of the Dragons, Robert's Rebellion, the
  Greyjoy Rebellion, the War of the Five Kings.
- Battles: the Trident, the Blackwater, the Whispering Wood, the Red Wedding
  (as event), the Field of Fire.
- Dragons: Balerion, Vhagar, Meraxes, Caraxes, Vhagar's riders, Drogon,
  Rhaegal, Viserion, and their riders.
- Cross-house marriages that shaped the story (e.g. Robert Baratheon betrothed to
  Lyanna Stark; Ned Stark and Catelyn Tully; Cersei Lannister and Robert
  Baratheon; Rhaegar Targaryen and Elia Martell).

## Completion checklist (stop when all true)

- [ ] `list_houses` returns all nine great houses, each `isGreatHouse: true`.
- [ ] Every great house has a non-empty `bannerPath` and `framePath`, and
      `list_assets` shows the matching `houses/<slug>/banner.webp` and
      `.../frame.webp` objects.
- [ ] Each house has its seat as a `location` with `controllingHouseSlug` set.
- [ ] Each house has its core canonical members with correct `fatherSlug` /
      `motherSlug` lineage, plus titles and allegiances.
- [ ] Major marriages and member relations are recorded (including cross-house).
- [ ] Relations between the houses are recorded via `link_houses`.
- [ ] The major wars and their key battles exist, with participants and the
      deaths that occurred in them.
- [ ] Targaryen dragons and their riders are recorded.
- [ ] Key timeline events exist with participants.
- [ ] (Polish) Members have portraits where a good reference exists.
