///|
fn timeline_params(
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
  only_media? : Bool,
  local_only? : Bool,
) -> @api.Params {
  let params = page_params(limit?, max_id?, since_id?, min_id?)
  params.put_bool("only_media", only_media)
  params.put_bool("local", local_only)
  params
}

///|
pub async fn Client::get_public_timeline(
  self : Self,
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
  only_media? : Bool,
  local_only? : Bool,
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  status_array_response(
    self.call(
      GetPublicTimeline,
      query=timeline_params(
        limit?,
        max_id?,
        since_id?,
        min_id?,
        only_media?,
        local_only?,
      ),
    ),
  )
}

///|
pub async fn Client::get_local_timeline(
  self : Self,
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
  only_media? : Bool,
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  status_array_response(
    self.call(
      GetLocalTimeline,
      query=timeline_params(
        limit?,
        max_id?,
        since_id?,
        min_id?,
        only_media?,
        local_only=true,
      ),
    ),
  )
}

///|
pub async fn Client::get_home_timeline(
  self : Self,
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  status_array_response(
    self.call(
      GetHomeTimeline,
      query=page_params(limit?, max_id?, since_id?, min_id?),
    ),
  )
}

///|
pub async fn Client::get_tag_timeline(
  self : Self,
  hashtag : String,
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
  only_media? : Bool,
  local_only? : Bool,
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  status_array_response(
    self.call(
      GetTagTimeline(hashtag),
      query=timeline_params(
        limit?,
        max_id?,
        since_id?,
        min_id?,
        only_media?,
        local_only?,
      ),
    ),
  )
}

///|
pub async fn Client::get_list_timeline(
  self : Self,
  list_id : String,
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  status_array_response(
    self.call(
      GetListTimeline(list_id),
      query=page_params(limit?, max_id?, since_id?, min_id?),
    ),
  )
}
