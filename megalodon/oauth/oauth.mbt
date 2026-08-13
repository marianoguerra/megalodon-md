///|
pub(all) struct AppData {
  id : String
  name : String
  website : String?
  redirect_uri : String?
  client_id : String
  client_secret : String
  url : String?
  session_token : String?
  raw : Json
} derive(Eq, Debug)

///|
pub fn AppData::from_json(json : Json) -> AppData raise @api.MegalodonError {
  guard json is Object(fields) else {
    raise @api.InvalidEntity(entity="AppData", detail="expected an object")
  }
  fn string(key : String) -> String raise @api.MegalodonError {
    guard fields.get(key) is Some(String(value)) else {
      raise @api.InvalidEntity(entity="AppData", detail="missing `\{key}`")
    }
    value
  }
  fn optional(key : String) -> String? {
    match fields.get(key) {
      Some(String(value)) => Some(value)
      _ => None
    }
  }
  {
    id: string("id"),
    name: string("name"),
    website: optional("website"),
    redirect_uri: match optional("redirect_uri") {
      Some(value) => Some(value)
      None => optional("callbackUrl")
    },
    client_id: string("client_id"),
    client_secret: string("client_secret"),
    url: optional("url"),
    session_token: optional("token"),
    raw: json,
  }
}

///|
pub(all) struct TokenData {
  access_token : String
  token_type : String
  scope : String?
  created_at : Int64?
  expires_in : Int64?
  refresh_token : String?
  raw : Json
} derive(Eq, Debug)

///|
pub fn TokenData::from_json(json : Json) -> TokenData raise @api.MegalodonError {
  guard json is Object(fields) else {
    raise @api.InvalidEntity(entity="TokenData", detail="expected an object")
  }
  fn string(key : String) -> String raise @api.MegalodonError {
    guard fields.get(key) is Some(String(value)) else {
      raise @api.InvalidEntity(entity="TokenData", detail="missing `\{key}`")
    }
    value
  }
  fn optional_string(key : String) -> String? {
    match fields.get(key) {
      Some(String(value)) => Some(value)
      _ => None
    }
  }
  fn optional_int(key : String) -> Int64? {
    match fields.get(key) {
      Some(Number(value, ..)) => Some(value.to_int64())
      _ => None
    }
  }
  {
    access_token: string("access_token"),
    token_type: match optional_string("token_type") {
      Some(value) => value
      None => "Bearer"
    },
    scope: optional_string("scope"),
    created_at: optional_int("created_at"),
    expires_in: optional_int("expires_in"),
    refresh_token: optional_string("refresh_token"),
    raw: json,
  }
}
