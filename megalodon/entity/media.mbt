///|
pub(all) struct Attachment {
  id : String
  attachment_type : AttachmentType
  url : String
  preview_url : String?
  description : String?
  blurhash : String?
  raw : Json
} derive(Eq, Debug)

///|
pub fn Attachment::from_json(
  json : Json,
) -> Attachment raise @api.MegalodonError {
  let fields = object_of(json, "Attachment")
  {
    id: required_string(fields, "id", "Attachment"),
    attachment_type: AttachmentType::parse(
      required_string(fields, "type", "Attachment"),
    ),
    url: required_string(fields, "url", "Attachment"),
    preview_url: optional_string(fields, "preview_url"),
    description: optional_string(fields, "description"),
    blurhash: optional_string(fields, "blurhash"),
    raw: json,
  }
}

///|
pub fn Attachment::to_json(self : Self) -> Json {
  self.raw
}

///|
pub(all) struct AsyncAttachment {
  id : String
  attachment_type : AttachmentType
  url : String?
  raw : Json
} derive(Eq, Debug)

///|
pub fn AsyncAttachment::from_json(
  json : Json,
) -> AsyncAttachment raise @api.MegalodonError {
  let fields = object_of(json, "AsyncAttachment")
  {
    id: required_string(fields, "id", "AsyncAttachment"),
    attachment_type: AttachmentType::parse(
      required_string(fields, "type", "AsyncAttachment"),
    ),
    url: optional_string(fields, "url"),
    raw: json,
  }
}

///|
pub(all) enum UploadMedia {
  Attachment(Attachment)
  AsyncAttachment(AsyncAttachment)
} derive(Eq, Debug)

///|
pub fn UploadMedia::from_json(
  json : Json,
) -> UploadMedia raise @api.MegalodonError {
  let fields = object_of(json, "UploadMedia")
  match fields.get("url") {
    Some(String(_)) => Attachment(Attachment::from_json(json))
    _ => AsyncAttachment(AsyncAttachment::from_json(json))
  }
}
