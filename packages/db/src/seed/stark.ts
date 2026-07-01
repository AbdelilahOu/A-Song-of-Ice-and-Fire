import { eq } from "drizzle-orm";

import type { createDb } from "../index";
import {
  battle,
  battleParticipant,
  death,
  event,
  eventParticipant,
  house,
  houseRelation,
  location,
  marriage,
  member,
  memberRelation,
  memberTitle,
  war,
  warParticipant,
} from "../schema";

type Db = ReturnType<typeof createDb>;

// Canonical data centred on House Stark (ASOIAF, ~300 AC). Years use the
// Aegon's Conquest epoch (AC). Values are drawn from the books/show and the
// A Wiki of Ice and Fire consensus timeline.

const houses = [
  {
    slug: "stark",
    name: "Stark",
    fullName: "House Stark of Winterfell",
    words: "Winter Is Coming",
    region: "The North",
    seat: "Winterfell",
    sigilDescription: "A grey direwolf running on a white field",
    sigilColors: "grey, white",
    status: "extant" as const,
    isGreatHouse: true,
    summary:
      "The Kings in the North of old and Wardens of the North, ruling the largest of the Seven Kingdoms from Winterfell for eight thousand years.",
  },
  {
    slug: "targaryen",
    name: "Targaryen",
    fullName: "House Targaryen of Dragonstone",
    words: "Fire and Blood",
    region: "The Crownlands",
    seat: "Dragonstone",
    sigilDescription: "A red three-headed dragon on a black field",
    sigilColors: "red, black",
    status: "exiled" as const,
    isGreatHouse: true,
    summary:
      "The dragonlords of old Valyria who conquered and ruled the Seven Kingdoms for nearly three hundred years, until Robert's Rebellion cast them down.",
  },
  {
    slug: "lannister",
    name: "Lannister",
    fullName: "House Lannister of Casterly Rock",
    words: "Hear Me Roar",
    region: "The Westerlands",
    seat: "Casterly Rock",
    sigilDescription: "A golden lion on a crimson field",
    sigilColors: "gold, crimson",
    status: "extant" as const,
    isGreatHouse: true,
    summary:
      "The richest house in Westeros, mining the gold of Casterly Rock, proud and powerful lords of the Westerlands.",
  },
  {
    slug: "baratheon",
    name: "Baratheon",
    fullName: "House Baratheon of Storm's End",
    words: "Ours Is the Fury",
    region: "The Stormlands",
    seat: "Storm's End",
    sigilDescription: "A crowned black stag on a golden field",
    sigilColors: "black, gold",
    status: "ruling" as const,
    isGreatHouse: true,
    summary:
      "The youngest of the Great Houses, founded by Orys Baratheon; Robert Baratheon took the Iron Throne after the fall of the Targaryens.",
  },
  {
    slug: "tully",
    name: "Tully",
    fullName: "House Tully of Riverrun",
    words: "Family, Duty, Honor",
    region: "The Riverlands",
    seat: "Riverrun",
    sigilDescription: "A silver trout leaping on a field of red and blue",
    sigilColors: "red, blue, silver",
    status: "extant" as const,
    isGreatHouse: true,
    summary:
      "Lords of Riverrun and Lords Paramount of the Trident, raised to overlordship of the Riverlands by Aegon the Conqueror.",
  },
  {
    slug: "arryn",
    name: "Arryn",
    fullName: "House Arryn of the Eyrie",
    words: "As High as Honor",
    region: "The Vale",
    seat: "The Eyrie",
    sigilDescription: "A white falcon and crescent moon on a sky-blue field",
    sigilColors: "sky blue, cream, white",
    status: "extant" as const,
    isGreatHouse: true,
    summary:
      "Descendants of the Kings of Mountain and Vale, the Arryns rule the Vale from the impregnable Eyrie high in the Mountains of the Moon.",
  },
  {
    slug: "tyrell",
    name: "Tyrell",
    fullName: "House Tyrell of Highgarden",
    words: "Growing Strong",
    region: "The Reach",
    seat: "Highgarden",
    sigilDescription: "A golden rose on a green field",
    sigilColors: "gold, green",
    status: "extant" as const,
    isGreatHouse: true,
    summary:
      "Lords of Highgarden and Wardens of the South, the Tyrells command the wealth and chivalry of the fertile Reach.",
  },
  {
    slug: "martell",
    name: "Martell",
    fullName: "House Nymeros Martell of Sunspear",
    words: "Unbowed, Unbent, Unbroken",
    region: "Dorne",
    seat: "Sunspear",
    sigilDescription: "A red sun pierced by a golden spear",
    sigilColors: "red, orange, gold",
    status: "extant" as const,
    isGreatHouse: true,
    summary:
      "The Princes of Dorne, who joined the realm through marriage rather than conquest and kept their own laws and customs.",
  },
  {
    slug: "greyjoy",
    name: "Greyjoy",
    fullName: "House Greyjoy of Pyke",
    words: "We Do Not Sow",
    region: "The Iron Islands",
    seat: "Pyke",
    sigilDescription: "A golden kraken on a black field",
    sigilColors: "gold, black",
    status: "extant" as const,
    isGreatHouse: true,
    summary:
      "The ironborn lords of Pyke, reavers who follow the Old Way of the Drowned God and once styled themselves Kings of the Iron Islands.",
  },
];

const locations = [
  {
    slug: "winterfell",
    name: "Winterfell",
    type: "castle" as const,
    region: "The North",
    controllingHouseSlug: "stark",
    description: "The ancient seat of House Stark, built over natural hot springs.",
  },
  {
    slug: "kings-landing",
    name: "King's Landing",
    type: "city" as const,
    region: "The Crownlands",
    controllingHouseSlug: "baratheon",
    description: "The capital of the Seven Kingdoms and seat of the Iron Throne.",
  },
  {
    slug: "the-twins",
    name: "The Twins",
    type: "castle" as const,
    region: "The Riverlands",
    controllingHouseSlug: null,
    description: "A pair of towers spanning the Green Fork, seat of House Frey.",
  },
  {
    slug: "tower-of-joy",
    name: "The Tower of Joy",
    type: "landmark" as const,
    region: "The Red Mountains of Dorne",
    controllingHouseSlug: null,
    description: "A tower in the Red Mountains where Lyanna Stark died.",
  },
  {
    slug: "the-trident",
    name: "The Trident",
    type: "landmark" as const,
    region: "The Riverlands",
    controllingHouseSlug: null,
    description: "The great river where the rebels broke the royalist army.",
  },
];

// houseSlug: null means the member is not a Stark (spouse/parent from elsewhere).
const members = [
  // --- Elder Stark generation ---
  {
    slug: "rickard-stark",
    name: "Rickard",
    fullName: "Rickard Stark",
    surname: "Stark",
    epithet: null,
    houseSlug: "stark",
    fatherSlug: null,
    motherSlug: null,
    gender: "male" as const,
    status: "dead" as const,
    bornYear: 244,
    diedYear: 282,
    notableFor: "Lord of Winterfell, burned alive by King Aerys II.",
    bio: "Lord of Winterfell and Warden of the North. He was murdered by Aerys II Targaryen after riding to King's Landing to answer for his son Brandon.",
  },
  {
    slug: "lyarra-stark",
    name: "Lyarra",
    fullName: "Lyarra Stark",
    surname: "Stark",
    epithet: null,
    houseSlug: "stark",
    fatherSlug: null,
    motherSlug: null,
    gender: "female" as const,
    status: "dead" as const,
    bornYear: 250,
    diedYear: 266,
    notableFor: "Lady of Winterfell, wife and cousin of Rickard Stark.",
    bio: "A Stark by birth who married her kinsman Rickard Stark and bore his four children.",
  },
  {
    slug: "brandon-stark-elder",
    name: "Brandon",
    fullName: "Brandon Stark",
    surname: "Stark",
    epithet: "The Wild Wolf",
    houseSlug: "stark",
    fatherSlug: "rickard-stark",
    motherSlug: "lyarra-stark",
    gender: "male" as const,
    status: "dead" as const,
    bornYear: 262,
    diedYear: 282,
    notableFor: "Heir to Winterfell, strangled before his father's eyes.",
    bio: "The hot-tempered elder son of Rickard, betrothed to Catelyn Tully. He was executed by Aerys II alongside his father.",
  },
  {
    slug: "eddard-stark",
    name: "Ned",
    fullName: "Eddard Stark",
    surname: "Stark",
    epithet: null,
    houseSlug: "stark",
    fatherSlug: "rickard-stark",
    motherSlug: "lyarra-stark",
    gender: "male" as const,
    status: "dead" as const,
    bornYear: 263,
    diedYear: 298,
    notableFor: "Lord of Winterfell, Warden of the North, Hand of the King.",
    bio: "Honourable second son who became Lord of Winterfell after the deaths of his father and elder brother. He helped Robert Baratheon win the throne, later served as Hand of the King, and was executed for treason in King's Landing.",
  },
  {
    slug: "lyanna-stark",
    name: "Lyanna",
    fullName: "Lyanna Stark",
    surname: "Stark",
    epithet: null,
    houseSlug: "stark",
    fatherSlug: "rickard-stark",
    motherSlug: "lyarra-stark",
    gender: "female" as const,
    status: "dead" as const,
    bornYear: 266,
    diedYear: 283,
    notableFor: "Betrothed of Robert Baratheon; mother of Jon Snow.",
    bio: "Ned's wilful younger sister, betrothed to Robert Baratheon. Her disappearance with Rhaegar Targaryen helped spark Robert's Rebellion. She died at the Tower of Joy shortly after giving birth.",
  },
  {
    slug: "benjen-stark",
    name: "Benjen",
    fullName: "Benjen Stark",
    surname: "Stark",
    epithet: null,
    houseSlug: "stark",
    fatherSlug: "rickard-stark",
    motherSlug: "lyarra-stark",
    gender: "male" as const,
    status: "unknown" as const,
    bornYear: 267,
    diedYear: null,
    notableFor: "First Ranger of the Night's Watch.",
    bio: "The youngest son of Rickard, who took the black and rose to First Ranger. He went missing beyond the Wall.",
  },
  // --- Ned's wife (Tully) ---
  {
    slug: "catelyn-stark",
    name: "Catelyn",
    fullName: "Catelyn Tully",
    surname: "Tully",
    epithet: null,
    houseSlug: "tully",
    fatherSlug: null,
    motherSlug: null,
    gender: "female" as const,
    status: "dead" as const,
    bornYear: 264,
    diedYear: 299,
    notableFor: "Lady of Winterfell; killed at the Red Wedding.",
    bio: "Daughter of Lord Hoster Tully, first betrothed to Brandon Stark and then wed to Eddard. A devoted mother, she was murdered at the Red Wedding.",
  },
  // --- Lyanna's Targaryen love ---
  {
    slug: "rhaegar-targaryen",
    name: "Rhaegar",
    fullName: "Rhaegar Targaryen",
    surname: "Targaryen",
    epithet: "The Last Dragon",
    houseSlug: "targaryen",
    fatherSlug: null,
    motherSlug: null,
    gender: "male" as const,
    status: "dead" as const,
    bornYear: 259,
    diedYear: 283,
    notableFor: "Crown Prince of the Seven Kingdoms; father of Jon Snow.",
    bio: "The gifted and melancholy heir of Aerys II. His union with Lyanna Stark lit the flame of rebellion. He was slain by Robert Baratheon at the Trident.",
  },
  // --- Robert (Lyanna's betrothed) ---
  {
    slug: "robert-baratheon",
    name: "Robert",
    fullName: "Robert Baratheon",
    surname: "Baratheon",
    epithet: null,
    houseSlug: "baratheon",
    fatherSlug: null,
    motherSlug: null,
    gender: "male" as const,
    status: "dead" as const,
    bornYear: 262,
    diedYear: 298,
    notableFor: "Lord of Storm's End who won the Iron Throne.",
    bio: "Ned's closest friend, betrothed to Lyanna Stark. His rebellion toppled the Targaryens and made him king. He died in a hunting accident.",
  },
  // --- Ned & Catelyn's children ---
  {
    slug: "robb-stark",
    name: "Robb",
    fullName: "Robb Stark",
    surname: "Stark",
    epithet: "The Young Wolf",
    houseSlug: "stark",
    fatherSlug: "eddard-stark",
    motherSlug: "catelyn-stark",
    gender: "male" as const,
    status: "dead" as const,
    bornYear: 283,
    diedYear: 299,
    notableFor: "King in the North; killed at the Red Wedding.",
    bio: "The eldest trueborn son of Ned and Catelyn, proclaimed King in the North after his father's execution. Undefeated in the field, he was betrayed and slain at the Red Wedding.",
  },
  {
    slug: "sansa-stark",
    name: "Sansa",
    fullName: "Sansa Stark",
    surname: "Stark",
    epithet: null,
    houseSlug: "stark",
    fatherSlug: "eddard-stark",
    motherSlug: "catelyn-stark",
    gender: "female" as const,
    status: "alive" as const,
    bornYear: 286,
    diedYear: null,
    notableFor: "Eldest Stark daughter; briefly wed to Tyrion Lannister.",
    bio: "The courteous elder daughter, held hostage in King's Landing and married to Tyrion Lannister against her will.",
  },
  {
    slug: "arya-stark",
    name: "Arya",
    fullName: "Arya Stark",
    surname: "Stark",
    epithet: null,
    houseSlug: "stark",
    fatherSlug: "eddard-stark",
    motherSlug: "catelyn-stark",
    gender: "female" as const,
    status: "alive" as const,
    bornYear: 289,
    diedYear: null,
    notableFor: "The wolf-blooded younger Stark daughter.",
    bio: "Fierce and wilful, Arya escaped King's Landing after her father's fall and walked a long, dark road toward becoming no one.",
  },
  {
    slug: "bran-stark",
    name: "Bran",
    fullName: "Brandon Stark",
    surname: "Stark",
    epithet: "The Broken",
    houseSlug: "stark",
    fatherSlug: "eddard-stark",
    motherSlug: "catelyn-stark",
    gender: "male" as const,
    status: "alive" as const,
    bornYear: 290,
    diedYear: null,
    notableFor: "A greenseer and warg, named for Brandon the Builder.",
    bio: "Crippled by a fall from a tower, Bran journeyed beyond the Wall to become a powerful greenseer.",
  },
  {
    slug: "rickon-stark",
    name: "Rickon",
    fullName: "Rickon Stark",
    surname: "Stark",
    epithet: null,
    houseSlug: "stark",
    fatherSlug: "eddard-stark",
    motherSlug: "catelyn-stark",
    gender: "male" as const,
    status: "alive" as const,
    bornYear: 295,
    diedYear: null,
    notableFor: "The youngest trueborn Stark child.",
    bio: "The wild youngest son of Ned and Catelyn, hidden away after the fall of Winterfell.",
  },
  // --- Jon Snow (Lyanna + Rhaegar) ---
  {
    slug: "jon-snow",
    name: "Jon",
    fullName: "Jon Snow",
    surname: "Snow",
    epithet: null,
    houseSlug: "stark",
    fatherSlug: "rhaegar-targaryen",
    motherSlug: "lyanna-stark",
    gender: "male" as const,
    status: "alive" as const,
    bornYear: 283,
    diedYear: null,
    isBastard: true,
    notableFor: "Raised as Ned Stark's bastard; Lord Commander of the Night's Watch.",
    bio: "Presented to the world as Eddard Stark's natural son, Jon was in truth the child of Lyanna Stark and Rhaegar Targaryen. He took the black and rose to Lord Commander of the Night's Watch.",
  },
  // --- Robb's wife ---
  {
    slug: "jeyne-westerling",
    name: "Jeyne",
    fullName: "Jeyne Westerling",
    surname: "Westerling",
    epithet: null,
    houseSlug: null,
    fatherSlug: null,
    motherSlug: null,
    gender: "female" as const,
    status: "alive" as const,
    bornYear: 280,
    diedYear: null,
    notableFor: "Wife of Robb Stark of House Westerling.",
    bio: "A daughter of House Westerling of the Crag whose marriage to Robb Stark cost him the loyalty of House Frey.",
  },
  // --- Sansa's husband ---
  {
    slug: "tyrion-lannister",
    name: "Tyrion",
    fullName: "Tyrion Lannister",
    surname: "Lannister",
    epithet: "The Imp",
    houseSlug: "lannister",
    fatherSlug: null,
    motherSlug: null,
    gender: "male" as const,
    status: "alive" as const,
    bornYear: 273,
    diedYear: null,
    notableFor: "Youngest child of Tywin Lannister; briefly wed to Sansa Stark.",
    bio: "The sharp-witted dwarf son of Tywin Lannister, married to Sansa Stark while she was a hostage in King's Landing.",
  },
];

const titles: { memberSlug: string; title: string; startYear?: number; isCurrent?: boolean }[] = [
  { memberSlug: "rickard-stark", title: "Lord of Winterfell", startYear: 266 },
  { memberSlug: "rickard-stark", title: "Warden of the North", startYear: 266 },
  { memberSlug: "eddard-stark", title: "Lord of Winterfell", startYear: 283, isCurrent: true },
  { memberSlug: "eddard-stark", title: "Warden of the North", startYear: 283, isCurrent: true },
  { memberSlug: "eddard-stark", title: "Hand of the King", startYear: 298 },
  { memberSlug: "brandon-stark-elder", title: "Heir to Winterfell", startYear: 266 },
  { memberSlug: "benjen-stark", title: "First Ranger of the Night's Watch" },
  { memberSlug: "robb-stark", title: "Lord of Winterfell", startYear: 298 },
  { memberSlug: "robb-stark", title: "King in the North", startYear: 298 },
  { memberSlug: "jon-snow", title: "Lord Commander of the Night's Watch", startYear: 300 },
  { memberSlug: "robert-baratheon", title: "King of the Andals and the First Men", startYear: 283 },
  { memberSlug: "rhaegar-targaryen", title: "Prince of Dragonstone", startYear: 259 },
];

const marriages: {
  aSlug: string;
  bSlug: string;
  status: "married" | "widowed" | "annulled" | "separated" | "betrothed";
  startYear?: number;
  isSecret?: boolean;
  notes?: string;
}[] = [
  { aSlug: "rickard-stark", bSlug: "lyarra-stark", status: "married", startYear: 261 },
  { aSlug: "eddard-stark", bSlug: "catelyn-stark", status: "married", startYear: 283 },
  { aSlug: "robb-stark", bSlug: "jeyne-westerling", status: "married", startYear: 299 },
  {
    aSlug: "sansa-stark",
    bSlug: "tyrion-lannister",
    status: "married",
    startYear: 300,
    notes: "A political match forced by House Lannister; never consummated.",
  },
  {
    aSlug: "rhaegar-targaryen",
    bSlug: "lyanna-stark",
    status: "married",
    startYear: 282,
    isSecret: true,
    notes: "A secret union; its validity is disputed. Jon Snow was their child.",
  },
];

const relations: { fromSlug: string; toSlug: string; type: "betrothed"; notes?: string }[] = [
  {
    fromSlug: "robert-baratheon",
    toSlug: "lyanna-stark",
    type: "betrothed",
    notes: "Robert was betrothed to Lyanna before her disappearance.",
  },
  {
    fromSlug: "brandon-stark-elder",
    toSlug: "catelyn-stark",
    type: "betrothed",
    notes: "Catelyn was first betrothed to Brandon before his death.",
  },
];

const deaths: {
  memberSlug: string;
  year: number;
  cause: string;
  locationSlug?: string;
  killerSlug?: string;
  battleSlug?: string;
  description?: string;
}[] = [
  {
    memberSlug: "lyarra-stark",
    year: 266,
    cause: "Illness",
    locationSlug: "winterfell",
  },
  {
    memberSlug: "rickard-stark",
    year: 282,
    cause: "Burned alive",
    locationSlug: "kings-landing",
    description: "Roasted in his armour by order of King Aerys II Targaryen.",
  },
  {
    memberSlug: "brandon-stark-elder",
    year: 282,
    cause: "Strangulation",
    locationSlug: "kings-landing",
    description: "Strangled himself trying to reach a sword to save his father.",
  },
  {
    memberSlug: "rhaegar-targaryen",
    year: 283,
    cause: "Slain in battle",
    locationSlug: "the-trident",
    killerSlug: "robert-baratheon",
    battleSlug: "battle-of-the-trident",
    description: "Struck down by Robert Baratheon's warhammer at the Trident.",
  },
  {
    memberSlug: "lyanna-stark",
    year: 283,
    cause: "Fever after childbirth",
    locationSlug: "tower-of-joy",
    description: "Died in a bed of blood at the Tower of Joy.",
  },
  {
    memberSlug: "robert-baratheon",
    year: 298,
    cause: "Hunting accident",
    locationSlug: "kings-landing",
    description: "Gored by a boar after being given too much strongwine.",
  },
  {
    memberSlug: "eddard-stark",
    year: 298,
    cause: "Beheading",
    locationSlug: "kings-landing",
    description: "Beheaded with his own sword Ice on the orders of King Joffrey.",
  },
  {
    memberSlug: "catelyn-stark",
    year: 299,
    cause: "Throat cut",
    locationSlug: "the-twins",
    description: "Murdered at the Red Wedding.",
  },
  {
    memberSlug: "robb-stark",
    year: 299,
    cause: "Killed at the Red Wedding",
    locationSlug: "the-twins",
    description: "Crossbowed and stabbed after the feast turned to slaughter.",
  },
];

const wars = [
  {
    slug: "roberts-rebellion",
    name: "Robert's Rebellion",
    startYear: 282,
    endYear: 283,
    outcome: "Victory for the rebels; House Targaryen deposed.",
    victorHouseSlug: "baratheon",
    description:
      "Also called the War of the Usurper. Sparked by the deaths of Rickard and Brandon Stark and the disappearance of Lyanna, it ended the Targaryen dynasty.",
  },
  {
    slug: "war-of-the-five-kings",
    name: "War of the Five Kings",
    startYear: 298,
    endYear: 300,
    outcome: "Ongoing; devastating for the Riverlands and the North.",
    victorHouseSlug: null,
    description:
      "The multi-sided war that erupted after the death of Robert Baratheon, pitting Stark, Lannister, Baratheon and Greyjoy claimants against one another.",
  },
];

const battles = [
  {
    slug: "battle-of-the-trident",
    name: "The Battle of the Trident",
    warSlug: "roberts-rebellion",
    year: 283,
    locationSlug: "the-trident",
    outcome: "Decisive rebel victory.",
    victorSide: "Rebels",
    description:
      "The pivotal battle where Robert Baratheon slew Prince Rhaegar Targaryen, breaking the royalist cause.",
  },
];

const warParticipants: {
  warSlug: string;
  houseSlug: string;
  side: string;
  role?: "attacker" | "defender" | "instigator" | "ally" | "commander" | "combatant";
  outcome?: string;
}[] = [
  {
    warSlug: "roberts-rebellion",
    houseSlug: "stark",
    side: "Rebels",
    role: "ally",
    outcome: "victor",
  },
  {
    warSlug: "roberts-rebellion",
    houseSlug: "baratheon",
    side: "Rebels",
    role: "instigator",
    outcome: "victor",
  },
  {
    warSlug: "roberts-rebellion",
    houseSlug: "tully",
    side: "Rebels",
    role: "ally",
    outcome: "victor",
  },
  {
    warSlug: "roberts-rebellion",
    houseSlug: "arryn",
    side: "Rebels",
    role: "ally",
    outcome: "victor",
  },
  {
    warSlug: "roberts-rebellion",
    houseSlug: "targaryen",
    side: "Loyalists",
    role: "defender",
    outcome: "defeated",
  },
  { warSlug: "war-of-the-five-kings", houseSlug: "stark", side: "The North", role: "combatant" },
  {
    warSlug: "war-of-the-five-kings",
    houseSlug: "lannister",
    side: "The Crown",
    role: "combatant",
  },
  {
    warSlug: "war-of-the-five-kings",
    houseSlug: "baratheon",
    side: "Stormlands claimants",
    role: "combatant",
  },
  {
    warSlug: "war-of-the-five-kings",
    houseSlug: "greyjoy",
    side: "The Iron Islands",
    role: "combatant",
  },
];

const battleParticipants: {
  battleSlug: string;
  memberSlug: string;
  side: string;
  role?: "attacker" | "defender" | "instigator" | "ally" | "commander" | "combatant";
  wasCommander?: boolean;
  wasKilled?: boolean;
}[] = [
  {
    battleSlug: "battle-of-the-trident",
    memberSlug: "robert-baratheon",
    side: "Rebels",
    role: "commander",
    wasCommander: true,
  },
  {
    battleSlug: "battle-of-the-trident",
    memberSlug: "rhaegar-targaryen",
    side: "Loyalists",
    role: "commander",
    wasCommander: true,
    wasKilled: true,
  },
];

const houseRelations: {
  aSlug: string;
  bSlug: string;
  type: "alliance" | "rivalry" | "feud" | "war" | "vassalage" | "cadet_branch" | "marriage_pact";
  startYear?: number;
  isCurrent?: boolean;
  description?: string;
}[] = [
  {
    aSlug: "stark",
    bSlug: "tully",
    type: "marriage_pact",
    startYear: 283,
    description: "Bound by the marriage of Eddard Stark and Catelyn Tully.",
  },
  {
    aSlug: "stark",
    bSlug: "baratheon",
    type: "alliance",
    startYear: 282,
    description: "Forged in Robert's Rebellion through the bond between Ned and Robert.",
  },
  {
    aSlug: "stark",
    bSlug: "arryn",
    type: "alliance",
    startYear: 282,
    description: "Ned Stark and Robert Baratheon were both wards of Jon Arryn.",
  },
  {
    aSlug: "stark",
    bSlug: "lannister",
    type: "war",
    startYear: 298,
    description: "Open war during the War of the Five Kings.",
  },
];

const events = [
  {
    slug: "tourney-at-harrenhal",
    name: "The Tourney at Harrenhal",
    type: "other" as const,
    year: 281,
    locationSlug: null,
    description:
      "The great tourney where Rhaegar Targaryen crowned Lyanna Stark queen of love and beauty, sowing the seeds of rebellion.",
    participants: [
      { memberSlug: "rhaegar-targaryen", role: "instigator" as const },
      { memberSlug: "lyanna-stark", role: "subject" as const },
      { memberSlug: "robert-baratheon", role: "witness" as const },
    ],
  },
  {
    slug: "execution-of-eddard-stark",
    name: "The Execution of Eddard Stark",
    type: "death" as const,
    year: 298,
    locationSlug: "kings-landing",
    description:
      "Ned Stark was beheaded on the steps of the Great Sept of Baelor on the order of King Joffrey.",
    participants: [
      { memberSlug: "eddard-stark", role: "victim" as const },
      { memberSlug: "sansa-stark", role: "witness" as const },
      { memberSlug: "arya-stark", role: "witness" as const },
    ],
  },
  {
    slug: "the-red-wedding",
    name: "The Red Wedding",
    type: "betrayal" as const,
    year: 299,
    locationSlug: "the-twins",
    description:
      "Robb Stark, his mother Catelyn, and much of the northern army were massacred under guest right at the Twins.",
    participants: [
      { memberSlug: "robb-stark", role: "victim" as const },
      { memberSlug: "catelyn-stark", role: "victim" as const },
    ],
  },
];

/**
 * Seeds the database with House Stark and the surrounding world. Idempotent:
 * clears all domain tables first, then inserts fresh. Auth tables are untouched.
 */
export async function seedStark(db: Db) {
  // Clear domain tables in FK-safe order.
  await db.delete(eventParticipant);
  await db.delete(event);
  await db.delete(battleParticipant);
  await db.delete(warParticipant);
  await db.delete(battle);
  await db.delete(war);
  await db.delete(death);
  await db.delete(memberRelation);
  await db.delete(marriage);
  await db.delete(memberTitle);
  await db.delete(houseRelation);
  await db.delete(member);
  await db.delete(location);
  await db.delete(house);

  // D1 caps bound variables per statement (~100), so insert row by row.

  // Houses
  const houseId = new Map<string, number>();
  for (const h of houses) {
    const [row] = await db
      .insert(house)
      .values({
        slug: h.slug,
        name: h.name,
        fullName: h.fullName,
        words: h.words,
        region: h.region,
        seat: h.seat,
        sigilDescription: h.sigilDescription,
        sigilColors: h.sigilColors,
        status: h.status,
        isGreatHouse: h.isGreatHouse,
        summary: h.summary,
        bannerPath: `/houses/${h.slug}/banner.png`,
        framePath: `/houses/${h.slug}/frame.png`,
      })
      .returning({ id: house.id, slug: house.slug });
    houseId.set(row!.slug, row!.id);
  }

  // Locations
  const locationId = new Map<string, number>();
  for (const l of locations) {
    const [row] = await db
      .insert(location)
      .values({
        slug: l.slug,
        name: l.name,
        type: l.type,
        region: l.region,
        controllingHouseId: l.controllingHouseSlug ? houseId.get(l.controllingHouseSlug) : null,
        description: l.description,
      })
      .returning({ id: location.id, slug: location.slug });
    locationId.set(row!.slug, row!.id);
  }

  // Members (lineage wired in a second pass once ids exist)
  const memberId = new Map<string, number>();
  for (const m of members) {
    const [row] = await db
      .insert(member)
      .values({
        slug: m.slug,
        name: m.name,
        fullName: m.fullName,
        surname: m.surname,
        epithet: m.epithet ?? null,
        houseId: m.houseSlug ? houseId.get(m.houseSlug) : null,
        gender: m.gender,
        status: m.status,
        isBastard: m.isBastard ?? false,
        bornYear: m.bornYear,
        diedYear: m.diedYear,
        notableFor: m.notableFor,
        bio: m.bio,
      })
      .returning({ id: member.id, slug: member.slug });
    memberId.set(row!.slug, row!.id);
  }

  for (const m of members) {
    if (!m.fatherSlug && !m.motherSlug) continue;
    await db
      .update(member)
      .set({
        fatherId: m.fatherSlug ? memberId.get(m.fatherSlug) : null,
        motherId: m.motherSlug ? memberId.get(m.motherSlug) : null,
      })
      .where(eq(member.slug, m.slug));
  }

  // Titles
  for (const t of titles) {
    await db.insert(memberTitle).values({
      memberId: memberId.get(t.memberSlug)!,
      title: t.title,
      startYear: t.startYear ?? null,
      isCurrent: t.isCurrent ?? false,
    });
  }

  // Marriages
  for (const mar of marriages) {
    await db.insert(marriage).values({
      spouseAId: memberId.get(mar.aSlug)!,
      spouseBId: memberId.get(mar.bSlug)!,
      status: mar.status,
      startYear: mar.startYear ?? null,
      isSecret: mar.isSecret ?? false,
      notes: mar.notes ?? null,
    });
  }

  // Non-lineage member relations
  for (const r of relations) {
    await db.insert(memberRelation).values({
      fromMemberId: memberId.get(r.fromSlug)!,
      toMemberId: memberId.get(r.toSlug)!,
      type: r.type,
      notes: r.notes ?? null,
    });
  }

  // House-to-house relations
  for (const r of houseRelations) {
    await db.insert(houseRelation).values({
      houseAId: houseId.get(r.aSlug)!,
      houseBId: houseId.get(r.bSlug)!,
      type: r.type,
      startYear: r.startYear ?? null,
      isCurrent: r.isCurrent ?? true,
      description: r.description ?? null,
    });
  }

  // Wars
  const warId = new Map<string, number>();
  for (const w of wars) {
    const [row] = await db
      .insert(war)
      .values({
        slug: w.slug,
        name: w.name,
        startYear: w.startYear,
        endYear: w.endYear,
        outcome: w.outcome,
        victorHouseId: w.victorHouseSlug ? houseId.get(w.victorHouseSlug) : null,
        description: w.description,
      })
      .returning({ id: war.id, slug: war.slug });
    warId.set(row!.slug, row!.id);
  }

  // Battles
  const battleId = new Map<string, number>();
  for (const b of battles) {
    const [row] = await db
      .insert(battle)
      .values({
        slug: b.slug,
        name: b.name,
        warId: b.warSlug ? warId.get(b.warSlug) : null,
        year: b.year,
        locationId: b.locationSlug ? locationId.get(b.locationSlug) : null,
        outcome: b.outcome,
        victorSide: b.victorSide,
        description: b.description,
      })
      .returning({ id: battle.id, slug: battle.slug });
    battleId.set(row!.slug, row!.id);
  }

  // Deaths (now that battles/locations exist)
  for (const d of deaths) {
    await db.insert(death).values({
      memberId: memberId.get(d.memberSlug)!,
      year: d.year,
      cause: d.cause,
      locationId: d.locationSlug ? locationId.get(d.locationSlug) : null,
      killerId: d.killerSlug ? memberId.get(d.killerSlug) : null,
      battleId: d.battleSlug ? battleId.get(d.battleSlug) : null,
      description: d.description ?? null,
    });
  }

  // War participants
  for (const p of warParticipants) {
    await db.insert(warParticipant).values({
      warId: warId.get(p.warSlug)!,
      houseId: houseId.get(p.houseSlug)!,
      side: p.side,
      role: p.role ?? null,
      outcome: p.outcome ?? null,
    });
  }

  // Battle participants
  for (const p of battleParticipants) {
    await db.insert(battleParticipant).values({
      battleId: battleId.get(p.battleSlug)!,
      memberId: memberId.get(p.memberSlug)!,
      side: p.side,
      role: p.role ?? null,
      wasCommander: p.wasCommander ?? false,
      wasKilled: p.wasKilled ?? false,
    });
  }

  // Events + participants
  for (const e of events) {
    const [row] = await db
      .insert(event)
      .values({
        slug: e.slug,
        name: e.name,
        type: e.type,
        year: e.year,
        locationId: e.locationSlug ? locationId.get(e.locationSlug) : null,
        description: e.description,
      })
      .returning({ id: event.id });
    for (const p of e.participants) {
      await db.insert(eventParticipant).values({
        eventId: row!.id,
        memberId: memberId.get(p.memberSlug)!,
        role: p.role,
      });
    }
  }

  return {
    houses: houses.length,
    members: members.length,
    wars: wars.length,
    battles: battles.length,
    events: events.length,
  };
}
