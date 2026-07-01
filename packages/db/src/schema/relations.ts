import { relations } from "drizzle-orm";

import { battle, battleParticipant, war, warParticipant } from "./conflicts";
import { dragon, dragonRider } from "./dragons";
import { death, event, eventParticipant } from "./events";
import { house, houseRelation } from "./houses";
import { location } from "./locations";
import {
  marriage,
  member,
  memberAllegiance,
  memberRelation,
  memberTitle,
} from "./members";

export const houseRelations = relations(house, ({ many }) => ({
  members: many(member, { relationName: "houseMembers" }),
  lord: many(member, { relationName: "houseLord" }),
  founder: many(member, { relationName: "houseFounder" }),
  relationsA: many(houseRelation, { relationName: "houseRelationA" }),
  relationsB: many(houseRelation, { relationName: "houseRelationB" }),
  locations: many(location),
  allegiances: many(memberAllegiance),
  warsWon: many(war),
}));

export const memberRelations = relations(member, ({ one, many }) => ({
  house: one(house, {
    fields: [member.houseId],
    references: [house.id],
    relationName: "houseMembers",
  }),
  leadsHouse: one(house, {
    fields: [member.id],
    references: [house.currentLordId],
    relationName: "houseLord",
  }),
  foundedHouse: one(house, {
    fields: [member.id],
    references: [house.founderId],
    relationName: "houseFounder",
  }),
  father: one(member, {
    fields: [member.fatherId],
    references: [member.id],
    relationName: "memberFather",
  }),
  mother: one(member, {
    fields: [member.motherId],
    references: [member.id],
    relationName: "memberMother",
  }),
  childrenAsFather: many(member, { relationName: "memberFather" }),
  childrenAsMother: many(member, { relationName: "memberMother" }),
  titles: many(memberTitle),
  allegiances: many(memberAllegiance),
  marriagesAsA: many(marriage, { relationName: "marriageSpouseA" }),
  marriagesAsB: many(marriage, { relationName: "marriageSpouseB" }),
  relationsFrom: many(memberRelation, { relationName: "memberRelationFrom" }),
  relationsTo: many(memberRelation, { relationName: "memberRelationTo" }),
  ridership: many(dragonRider),
  notableDragons: many(dragon, { relationName: "dragonNotableRider" }),
  death: one(death, {
    fields: [member.id],
    references: [death.memberId],
    relationName: "memberDeath",
  }),
  kills: many(death, { relationName: "memberKills" }),
  warParticipations: many(warParticipant),
  battleParticipations: many(battleParticipant),
  eventParticipations: many(eventParticipant),
}));

export const houseRelationRelations = relations(houseRelation, ({ one }) => ({
  houseA: one(house, {
    fields: [houseRelation.houseAId],
    references: [house.id],
    relationName: "houseRelationA",
  }),
  houseB: one(house, {
    fields: [houseRelation.houseBId],
    references: [house.id],
    relationName: "houseRelationB",
  }),
}));

export const memberTitleRelations = relations(memberTitle, ({ one }) => ({
  member: one(member, {
    fields: [memberTitle.memberId],
    references: [member.id],
  }),
}));

export const marriageRelations = relations(marriage, ({ one }) => ({
  spouseA: one(member, {
    fields: [marriage.spouseAId],
    references: [member.id],
    relationName: "marriageSpouseA",
  }),
  spouseB: one(member, {
    fields: [marriage.spouseBId],
    references: [member.id],
    relationName: "marriageSpouseB",
  }),
}));

export const memberRelationRelations = relations(memberRelation, ({ one }) => ({
  from: one(member, {
    fields: [memberRelation.fromMemberId],
    references: [member.id],
    relationName: "memberRelationFrom",
  }),
  to: one(member, {
    fields: [memberRelation.toMemberId],
    references: [member.id],
    relationName: "memberRelationTo",
  }),
}));

export const memberAllegianceRelations = relations(
  memberAllegiance,
  ({ one }) => ({
    member: one(member, {
      fields: [memberAllegiance.memberId],
      references: [member.id],
    }),
    house: one(house, {
      fields: [memberAllegiance.houseId],
      references: [house.id],
    }),
  }),
);

export const locationRelations = relations(location, ({ one, many }) => ({
  controllingHouse: one(house, {
    fields: [location.controllingHouseId],
    references: [house.id],
  }),
  battles: many(battle),
  deaths: many(death),
  events: many(event),
}));

export const warRelations = relations(war, ({ one, many }) => ({
  victorHouse: one(house, {
    fields: [war.victorHouseId],
    references: [house.id],
  }),
  battles: many(battle),
  participants: many(warParticipant),
  events: many(event),
}));

export const battleRelations = relations(battle, ({ one, many }) => ({
  war: one(war, { fields: [battle.warId], references: [war.id] }),
  location: one(location, {
    fields: [battle.locationId],
    references: [location.id],
  }),
  participants: many(battleParticipant),
  deaths: many(death),
  dragonsKilled: many(dragon, { relationName: "dragonKilledInBattle" }),
  events: many(event),
}));

export const warParticipantRelations = relations(warParticipant, ({ one }) => ({
  war: one(war, { fields: [warParticipant.warId], references: [war.id] }),
  house: one(house, {
    fields: [warParticipant.houseId],
    references: [house.id],
  }),
  member: one(member, {
    fields: [warParticipant.memberId],
    references: [member.id],
  }),
}));

export const battleParticipantRelations = relations(
  battleParticipant,
  ({ one }) => ({
    battle: one(battle, {
      fields: [battleParticipant.battleId],
      references: [battle.id],
    }),
    house: one(house, {
      fields: [battleParticipant.houseId],
      references: [house.id],
    }),
    member: one(member, {
      fields: [battleParticipant.memberId],
      references: [member.id],
    }),
  }),
);

export const dragonRelations = relations(dragon, ({ one, many }) => ({
  notableRider: one(member, {
    fields: [dragon.notableRiderId],
    references: [member.id],
    relationName: "dragonNotableRider",
  }),
  killedInBattle: one(battle, {
    fields: [dragon.killedInBattleId],
    references: [battle.id],
    relationName: "dragonKilledInBattle",
  }),
  riders: many(dragonRider),
}));

export const dragonRiderRelations = relations(dragonRider, ({ one }) => ({
  dragon: one(dragon, {
    fields: [dragonRider.dragonId],
    references: [dragon.id],
  }),
  member: one(member, {
    fields: [dragonRider.memberId],
    references: [member.id],
  }),
}));

export const deathRelations = relations(death, ({ one }) => ({
  killer: one(member, {
    fields: [death.killerId],
    references: [member.id],
    relationName: "memberKills",
  }),
  location: one(location, {
    fields: [death.locationId],
    references: [location.id],
  }),
  battle: one(battle, { fields: [death.battleId], references: [battle.id] }),
}));

export const eventRelations = relations(event, ({ one, many }) => ({
  location: one(location, {
    fields: [event.locationId],
    references: [location.id],
  }),
  war: one(war, { fields: [event.warId], references: [war.id] }),
  battle: one(battle, { fields: [event.battleId], references: [battle.id] }),
  participants: many(eventParticipant),
}));

export const eventParticipantRelations = relations(
  eventParticipant,
  ({ one }) => ({
    event: one(event, {
      fields: [eventParticipant.eventId],
      references: [event.id],
    }),
    member: one(member, {
      fields: [eventParticipant.memberId],
      references: [member.id],
    }),
    house: one(house, {
      fields: [eventParticipant.houseId],
      references: [house.id],
    }),
  }),
);
