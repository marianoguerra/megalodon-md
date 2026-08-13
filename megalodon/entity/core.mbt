///|
fn object_of(
  json : Json,
  entity : String,
) -> Map[String, Json] raise @api.MegalodonError {
  guard json is Object(fields) else {
    raise @api.InvalidEntity(entity~, detail="expected an object")
  }
  fields
}

///|
fn required_string(
  fields : Map[String, Json],
  key : String,
  entity : String,
) -> String raise @api.MegalodonError {
  guard fields.get(key) is Some(String(value)) else {
    raise @api.InvalidEntity(entity~, detail="missing string field `\{key}`")
  }
  value
}

///|
fn optional_string(fields : Map[String, Json], key : String) -> String? {
  match fields.get(key) {
    Some(String(value)) => Some(value)
    _ => None
  }
}

///|
fn required_bool(
  fields : Map[String, Json],
  key : String,
  entity : String,
) -> Bool raise @api.MegalodonError {
  match fields.get(key) {
    Some(True) => true
    Some(False) => false
    _ =>
      raise @api.InvalidEntity(entity~, detail="missing boolean field `\{key}`")
  }
}

///|
pub(all) enum StatusVisibility {
  Public
  Unlisted
  Private
  Direct
  Local
} derive(Eq, Debug)

///|
pub fn StatusVisibility::to_string(self : Self) -> String {
  match self {
    Public => "public"
    Unlisted => "unlisted"
    Private => "private"
    Direct => "direct"
    Local => "local"
  }
}

///|
pub fn StatusVisibility::parse(
  value : String,
) -> StatusVisibility raise @api.MegalodonError {
  match value {
    "public" => Public
    "unlisted" => Unlisted
    "private" => Private
    "direct" => Direct
    "local" => Local
    _ => raise @api.InvalidEntity(entity="StatusVisibility", detail=value)
  }
}

///|
pub(all) enum AttachmentType {
  Image
  Gifv
  Video
  Audio
  Unknown
} derive(Eq, Debug)

///|
pub fn AttachmentType::parse(value : String) -> AttachmentType {
  match value {
    "image" => Image
    "gifv" => Gifv
    "video" => Video
    "audio" => Audio
    _ => Unknown
  }
}

///|
pub fn AttachmentType::to_string(self : Self) -> String {
  match self {
    Image => "image"
    Gifv => "gifv"
    Video => "video"
    Audio => "audio"
    Unknown => "unknown"
  }
}

///|
pub(all) enum FilterContext {
  Home
  Notifications
  Public
  Thread
} derive(Eq, Debug)

///|
pub fn FilterContext::to_string(self : Self) -> String {
  match self {
    Home => "home"
    Notifications => "notifications"
    Public => "public"
    Thread => "thread"
  }
}

///|
pub(all) enum Category {
  Spam
  Violation
  Other
} derive(Eq, Debug)

///|
pub fn Category::to_string(self : Self) -> String {
  match self {
    Spam => "spam"
    Violation => "violation"
    Other => "other"
  }
}

///|
pub(all) enum NotificationType {
  Follow
  FollowRequest
  Mention
  Reblog
  Favourite
  PollVote
  PollExpired
  Status
  Reaction
  Update
  Move
  AdminSignup
  AdminReport
  GroupInvited
  App
  Quote
  QuotedUpdate
  Unknown
} derive(Eq, Debug)

///|
pub fn NotificationType::to_string(self : Self) -> String {
  match self {
    Follow => "follow"
    FollowRequest => "follow_request"
    Mention => "mention"
    Reblog => "reblog"
    Favourite => "favourite"
    PollVote => "poll_vote"
    PollExpired => "poll_expired"
    Status => "status"
    Reaction => "reaction"
    Update => "update"
    Move => "move"
    AdminSignup => "admin.sign_up"
    AdminReport => "admin.report"
    GroupInvited => "group_invited"
    App => "app"
    Quote => "quote"
    QuotedUpdate => "quoted_update"
    Unknown => "unknown"
  }
}

///|
pub fn NotificationType::parse(value : String) -> NotificationType {
  match value {
    "follow" => Follow
    "follow_request" => FollowRequest
    "mention" => Mention
    "reblog" => Reblog
    "favourite" => Favourite
    "poll_vote" => PollVote
    "poll" | "poll_expired" => PollExpired
    "status" => Status
    "pleroma:emoji_reaction" | "reaction" => Reaction
    "update" => Update
    "move" => Move
    "admin.sign_up" => AdminSignup
    "admin.report" => AdminReport
    "group_invited" => GroupInvited
    "app" => App
    "quote" => Quote
    "quoted_update" => QuotedUpdate
    _ => Unknown
  }
}

///|
pub(all) enum ExpandMedia {
  Default
  ShowAll
  HideAll
} derive(Eq, Debug)

///|
pub fn ExpandMedia::parse(
  value : String,
) -> ExpandMedia raise @api.MegalodonError {
  match value {
    "default" => Default
    "show_all" => ShowAll
    "hide_all" => HideAll
    _ => raise @api.InvalidEntity(entity="ExpandMedia", detail=value)
  }
}

///|
pub fn ExpandMedia::to_string(self : Self) -> String {
  match self {
    Default => "default"
    ShowAll => "show_all"
    HideAll => "hide_all"
  }
}
