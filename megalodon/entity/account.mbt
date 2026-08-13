///|
/// The normalized account fields shared by the supported server families.
/// `raw` preserves every vendor field verbatim.
pub(all) struct Account {
  id : String
  username : String
  acct : String
  display_name : String
  created_at : String
  note : String
  url : String
  avatar : String
  header : String
  locked : Bool
  bot : Bool
  raw : Json
} derive(Eq, Debug)

///|
pub fn Account::from_json(json : Json) -> Account raise @api.MegalodonError {
  let fields = object_of(json, "Account")
  {
    id: required_string(fields, "id", "Account"),
    username: required_string(fields, "username", "Account"),
    acct: required_string(fields, "acct", "Account"),
    display_name: required_string(fields, "display_name", "Account"),
    created_at: required_string(fields, "created_at", "Account"),
    note: required_string(fields, "note", "Account"),
    url: required_string(fields, "url", "Account"),
    avatar: required_string(fields, "avatar", "Account"),
    header: required_string(fields, "header", "Account"),
    locked: required_bool(fields, "locked", "Account"),
    bot: required_bool(fields, "bot", "Account"),
    raw: json,
  }
}

///|
pub fn Account::to_json(self : Self) -> Json {
  self.raw
}
