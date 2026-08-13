///|
pub(all) struct Status {
  id : String
  uri : String
  url : String?
  account : Account
  content : String
  /// Pleroma/Akkoma's optional plain-text rendering.
  plain_content : String?
  created_at : String
  spoiler_text : String
  sensitive : Bool
  visibility : StatusVisibility
  raw : Json
} derive(Eq, Debug)

///|
pub fn Status::from_json(json : Json) -> Status raise @api.MegalodonError {
  let fields = object_of(json, "Status")
  guard fields.get("account") is Some(account) else {
    raise @api.InvalidEntity(entity="Status", detail="missing account")
  }
  {
    id: required_string(fields, "id", "Status"),
    uri: required_string(fields, "uri", "Status"),
    url: optional_string(fields, "url"),
    account: Account::from_json(account),
    content: required_string(fields, "content", "Status"),
    plain_content: pleroma_plain_content(fields),
    created_at: required_string(fields, "created_at", "Status"),
    spoiler_text: required_string(fields, "spoiler_text", "Status"),
    sensitive: required_bool(fields, "sensitive", "Status"),
    visibility: StatusVisibility::parse(
      required_string(fields, "visibility", "Status"),
    ),
    raw: json,
  }
}

///|
fn pleroma_plain_content(fields : Map[String, Json]) -> String? {
  guard fields.get("pleroma") is Some(Object(pleroma)) else { return None }
  guard pleroma.get("content") is Some(Object(content)) else { return None }
  match content.get("text/plain") {
    Some(String(value)) => Some(value)
    _ => None
  }
}

///|
pub fn Status::to_json(self : Self) -> Json {
  self.raw
}

///|
pub(all) struct StatusParams {
  text : String
  spoiler_text : String?
  sensitive : Bool?
  language : String?
} derive(Eq, Debug)
