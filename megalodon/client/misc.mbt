///|
pub async fn Client::get_instance(
  self : Self,
) -> @api.Response[@entity.Instance] raise @api.MegalodonError {
  object_response(self.call(GetInstance), "Instance")
}

///|
pub async fn Client::get_instance_peers(
  self : Self,
) -> @api.Response[Array[String]] raise @api.MegalodonError {
  decode_response(self.call(GetInstancePeers), json => {
    guard json is Array(items) else {
      raise @api.InvalidEntity(
        entity="InstancePeers",
        detail="expected an array",
      )
    }
    let peers = []
    for item in items {
      guard item is String(value) else {
        raise @api.InvalidEntity(
          entity="InstancePeers",
          detail="expected strings",
        )
      }
      peers.push(value)
    }
    peers
  })
}

///|
pub async fn Client::get_notifications(
  self : Self,
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
  account_id? : String,
  exclude_types? : Array[@entity.NotificationType],
) -> @api.Response[Array[@entity.Notification]] raise @api.MegalodonError {
  let params = page_params(limit?, max_id?, since_id?, min_id?)
  params.put_string("account_id", account_id)
  params.put_strings(
    "exclude_types[]",
    exclude_types.map(values => values.map(value => value.to_string())),
  )
  decode_response(self.call(GetNotifications, query=params), json => {
    let decoded = decode_array(
      json,
      "Notification",
      @entity.Notification::from_json,
    )
    decoded.filter(item => item.notification_type != @entity.Unknown)
  })
}

///|
pub async fn Client::get_notification(
  self : Self,
  id : String,
) -> @api.Response[@entity.Notification] raise @api.MegalodonError {
  decode_response(
    self.call(GetNotification(id)),
    @entity.Notification::from_json,
  )
}

///|
pub async fn Client::dismiss_notification(
  self : Self,
  id : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(DismissNotification(id), body=@api.Json({}))
}

///|
pub async fn Client::dismiss_notifications(
  self : Self,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(DismissNotifications, body=@api.Json({}))
}

///|
pub async fn Client::search(
  self : Self,
  q : String,
  search_type? : SearchType,
  limit? : Int,
  max_id? : String,
  min_id? : String,
  resolve? : Bool,
  offset? : Int64,
  following? : Bool,
  account_id? : String,
  exclude_unreviewed? : Bool,
) -> @api.Response[@entity.Results] raise @api.MegalodonError {
  let params = page_params(limit?, max_id?, since_id?=None, min_id?)
  params.put_string("q", Some(q))
  params.put_string("type", search_type.map(value => value.to_string()))
  params.put_bool("resolve", resolve)
  params.put_int("offset", offset)
  params.put_bool("following", following)
  params.put_string("account_id", account_id)
  params.put_bool("exclude_unreviewed", exclude_unreviewed)
  object_response(self.call(Search, query=params), "Results")
}

///|
pub async fn Client::get_lists(
  self : Self,
) -> @api.Response[Array[@entity.List]] raise @api.MegalodonError {
  object_array_response(self.call(GetLists), "List")
}

///|
pub async fn Client::get_list(
  self : Self,
  id : String,
) -> @api.Response[@entity.List] raise @api.MegalodonError {
  object_response(self.call(GetList(id)), "List")
}

///|
pub async fn Client::create_list(
  self : Self,
  title : String,
) -> @api.Response[@entity.List] raise @api.MegalodonError {
  object_response(
    self.call(CreateList, body=@api.Json({ "title": title })),
    "List",
  )
}

///|
pub async fn Client::get_poll(
  self : Self,
  id : String,
) -> @api.Response[@entity.Poll] raise @api.MegalodonError {
  object_response(self.call(GetPoll(id)), "Poll")
}

///|
pub async fn Client::vote_poll(
  self : Self,
  id : String,
  choices : Array[Int64],
) -> @api.Response[@entity.Poll] raise @api.MegalodonError {
  object_response(
    self.call(
      VotePoll(id),
      body=@api.Json({
        "choices": Json::array(
          choices.map(value => Json::number(value.to_double())),
        ),
      }),
    ),
    "Poll",
  )
}

///|
pub async fn Client::get_media(
  self : Self,
  id : String,
) -> @api.Response[@entity.Attachment] raise @api.MegalodonError {
  decode_response(self.call(GetMedia(id)), @entity.Attachment::from_json)
}

///|
pub async fn Client::upload_media(
  self : Self,
  bytes : Bytes,
  mime_type : String,
  file_name? : String = "upload",
  description? : String,
  focus? : String,
  boundary? : String = "megalodon-moonbit-boundary",
) -> @api.Response[@entity.UploadMedia] raise @api.MegalodonError {
  let fields = []
  if description is Some(value) {
    fields.push(("description", value))
  }
  if focus is Some(value) {
    fields.push(("focus", value))
  }
  let multipart = @api.multipart_file(
    boundary,
    "file",
    file_name,
    mime_type,
    bytes,
    fields~,
  )
  decode_response(
    self.call(
      UploadMedia,
      body=@api.Raw(bytes=multipart.body, content_type=multipart.content_type),
    ),
    @entity.UploadMedia::from_json,
  )
}
