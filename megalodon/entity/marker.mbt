///|
pub(all) struct MarkerEntry {
  last_read_id : String
  version : Int64
  updated_at : String
  unread_count : Int64?
  raw : Json
} derive(Eq, Debug)

///|
pub(all) struct Marker {
  home : MarkerEntry?
  notifications : MarkerEntry?
  raw : Json
} derive(Eq, Debug)

///|
fn marker_entry(
  json : Json,
  name : String,
) -> MarkerEntry raise @api.MegalodonError {
  let fields = object_of(json, name)
  guard fields.get("version") is Some(Number(version, ..)) else {
    raise @api.InvalidEntity(
      entity=name,
      detail="missing numeric field `version`",
    )
  }
  let unread_count = match fields.get("pleroma") {
    Some(Object(pleroma)) =>
      match pleroma.get("unread_count") {
        Some(Number(value, ..)) => Some(value.to_int64())
        _ => None
      }
    _ => None
  }
  {
    last_read_id: required_string(fields, "last_read_id", name),
    version: version.to_int64(),
    updated_at: required_string(fields, "updated_at", name),
    unread_count,
    raw: json,
  }
}

///|
pub fn Marker::from_json(json : Json) -> Marker raise @api.MegalodonError {
  let fields = object_of(json, "Marker")
  let home = match fields.get("home") {
    Some(value) => Some(marker_entry(value, "Marker.home"))
    None => None
  }
  let notifications = match fields.get("notifications") {
    Some(value) => Some(marker_entry(value, "Marker.notifications"))
    None => None
  }
  { home, notifications, raw: json, }
}

///|
pub fn Marker::to_json(self : Self) -> Json {
  self.raw
}
