///|
fn status_response(
  response : @api.Response[Json],
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  decode_response(response, @entity.Status::from_json)
}

///|
fn status_array_response(
  response : @api.Response[Json],
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  decode_response(response, json => {
    decode_array(json, "Status", @entity.Status::from_json)
  })
}

///|
pub async fn Client::get_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  status_response(self.call(GetStatus(id)))
}

///|
pub async fn Client::post_status(
  self : Self,
  status : String,
  media_ids? : Array[String],
  in_reply_to_id? : String,
  sensitive? : Bool,
  spoiler_text? : String,
  visibility? : @entity.StatusVisibility,
  scheduled_at? : String,
  language? : String,
  quote_id? : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  let body : Map[String, Json] = { "status": status }
  if media_ids is Some(values) {
    body["media_ids"] = Json::array(values.map(Json::string))
  }
  if in_reply_to_id is Some(value) {
    body["in_reply_to_id"] = Json::string(value)
  }
  if sensitive is Some(value) {
    body["sensitive"] = Json::boolean(value)
  }
  if spoiler_text is Some(value) {
    body["spoiler_text"] = Json::string(value)
  }
  if visibility is Some(value) {
    body["visibility"] = Json::string(value.to_string())
  }
  if scheduled_at is Some(value) {
    body["scheduled_at"] = Json::string(value)
  }
  if language is Some(value) {
    body["language"] = Json::string(value)
  }
  if quote_id is Some(value) {
    body["quote_id"] = Json::string(value)
  }
  self.call(PostStatus, body=@api.Json(Json::object(body)))
}

///|
pub async fn Client::edit_status(
  self : Self,
  id : String,
  status? : String,
  media_ids? : Array[String],
  sensitive? : Bool,
  spoiler_text? : String,
  language? : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  let body : Map[String, Json] = Map([])
  if status is Some(value) {
    body["status"] = Json::string(value)
  }
  if media_ids is Some(values) {
    body["media_ids"] = Json::array(values.map(Json::string))
  }
  if sensitive is Some(value) {
    body["sensitive"] = Json::boolean(value)
  }
  if spoiler_text is Some(value) {
    body["spoiler_text"] = Json::string(value)
  }
  if language is Some(value) {
    body["language"] = Json::string(value)
  }
  status_response(self.call(EditStatus(id), body=@api.Json(Json::object(body))))
}

///|
pub async fn Client::delete_status(
  self : Self,
  id : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(DeleteStatus(id))
}

///|
async fn Client::status_action(
  self : Self,
  endpoint : Endpoint,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  status_response(self.call(endpoint, body=@api.Json({})))
}

///|
pub async fn Client::favourite_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(FavouriteStatus(id))
}

///|
pub async fn Client::unfavourite_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(UnfavouriteStatus(id))
}

///|
pub async fn Client::reblog_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(ReblogStatus(id))
}

///|
pub async fn Client::unreblog_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(UnreblogStatus(id))
}

///|
pub async fn Client::bookmark_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(BookmarkStatus(id))
}

///|
pub async fn Client::unbookmark_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(UnbookmarkStatus(id))
}

///|
pub async fn Client::mute_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(MuteStatus(id))
}

///|
pub async fn Client::unmute_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(UnmuteStatus(id))
}

///|
pub async fn Client::pin_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(PinStatus(id))
}

///|
pub async fn Client::unpin_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  self.status_action(UnpinStatus(id))
}
