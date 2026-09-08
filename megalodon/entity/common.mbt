///|
/// Common object wrapper used for entities whose complete, server-specific
/// shape remains available through `raw`.
pub(all) struct EntityObject {
  raw : Json
} derive(Eq, Debug)

///|
pub fn EntityObject::from_json(
  json : Json,
  name : String,
) -> EntityObject raise @api.MegalodonError {
  ignore(object_of(json, name))
  { raw: json, }
}

///|
pub fn EntityObject::to_json(self : Self) -> Json {
  self.raw
}

///|
pub type Activity = EntityObject

///|
pub type Announcement = EntityObject

///|
pub type Application = EntityObject

///|
pub type Card = EntityObject

///|
pub type Context = EntityObject

///|
pub type Conversation = EntityObject

///|
pub type Emoji = EntityObject

///|
pub type FeaturedTag = EntityObject

///|
pub type Field = EntityObject

///|
pub type Filter = EntityObject

///|
pub type FollowRequest = EntityObject

///|
pub type History = EntityObject

///|
pub type IdentityProof = EntityObject

///|
pub type Instance = EntityObject

///|
pub type List = EntityObject

///|
pub type Mention = EntityObject

///|
pub type Poll = EntityObject

///|
pub type PollOption = EntityObject

///|
pub type PushSubscription = EntityObject

///|
pub type Quote = EntityObject

///|
pub type QuotedStatus = EntityObject

///|
pub type ShallowQuote = EntityObject

///|
pub type QuoteApproval = EntityObject

///|
pub type Reaction = EntityObject

///|
pub type Relationship = EntityObject

///|
pub type Report = EntityObject

///|
pub type Results = EntityObject

///|
pub type Role = EntityObject

///|
pub type ScheduledStatus = EntityObject

///|
pub type Source = EntityObject

///|
pub type Stats = EntityObject

///|
pub type StatusSource = EntityObject

///|
pub type Tag = EntityObject

///|
pub type Token = EntityObject

///|
pub type URLs = EntityObject

///|
pub(all) enum QuoteState {
  Pending
  Accepted
  Rejected
  Revoked
  Deleted
  Unauthorized
  Unknown(String)
} derive(Eq, Debug)
