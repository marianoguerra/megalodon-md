///|
pub(all) struct Preferences {
  posting_default_visibility : StatusVisibility
  posting_default_sensitive : Bool
  posting_default_language : String?
  reading_expand_media : ExpandMedia
  reading_expand_spoilers : Bool
  raw : Json
} derive(Eq, Debug)

///|
pub fn Preferences::from_json(
  json : Json,
) -> Preferences raise @api.MegalodonError {
  let fields = object_of(json, "Preferences")
  {
    posting_default_visibility: StatusVisibility::parse(
      required_string(fields, "posting:default:visibility", "Preferences"),
    ),
    posting_default_sensitive: required_bool(
      fields, "posting:default:sensitive", "Preferences",
    ),
    posting_default_language: optional_string(
      fields, "posting:default:language",
    ),
    reading_expand_media: ExpandMedia::parse(
      required_string(fields, "reading:expand:media", "Preferences"),
    ),
    reading_expand_spoilers: required_bool(
      fields, "reading:expand:spoilers", "Preferences",
    ),
    raw: json,
  }
}

///|
pub fn Preferences::to_json(self : Self) -> Json {
  self.raw
}
