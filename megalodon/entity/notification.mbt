///|
/// A normalized notification. Unknown notification kinds decode as `Unknown`.
pub(all) struct Notification {
  id : String
  notification_type : NotificationType
  created_at : String
  account : Account
  status : Status?
  raw : Json
} derive(Eq, Debug)

///|
pub fn Notification::from_json(
  json : Json,
) -> Notification raise @api.MegalodonError {
  let fields = object_of(json, "Notification")
  guard fields.get("account") is Some(account) else {
    raise @api.InvalidEntity(entity="Notification", detail="missing account")
  }
  let status = match fields.get("status") {
    Some(Null) | None => None
    Some(value) => Some(Status::from_json(value))
  }
  {
    id: required_string(fields, "id", "Notification"),
    notification_type: NotificationType::parse(
      required_string(fields, "type", "Notification"),
    ),
    created_at: required_string(fields, "created_at", "Notification"),
    account: Account::from_json(account),
    status,
    raw: json,
  }
}

///|
pub fn Notification::to_json(self : Self) -> Json {
  self.raw
}
