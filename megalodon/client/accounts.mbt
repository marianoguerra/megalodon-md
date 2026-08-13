///|
fn account_response(
  response : @api.Response[Json],
) -> @api.Response[@entity.Account] raise @api.MegalodonError {
  decode_response(response, @entity.Account::from_json)
}

///|
fn accounts_response(
  response : @api.Response[Json],
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  decode_response(response, json => {
    decode_array(json, "Account", @entity.Account::from_json)
  })
}

///|
pub async fn Client::verify_account_credentials(
  self : Self,
) -> @api.Response[@entity.Account] raise @api.MegalodonError {
  account_response(self.call(VerifyAccountCredentials))
}

///|
pub async fn Client::get_account(
  self : Self,
  id : String,
) -> @api.Response[@entity.Account] raise @api.MegalodonError {
  account_response(self.call(GetAccount(id)))
}

///|
pub async fn Client::get_account_statuses(
  self : Self,
  id : String,
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
  pinned? : Bool,
  exclude_replies? : Bool,
  exclude_reblogs? : Bool,
  only_media? : Bool,
  only_public? : Bool,
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  let params = page_params(limit?, max_id?, since_id?, min_id?)
  params.put_bool("pinned", pinned)
  params.put_bool("exclude_replies", exclude_replies)
  params.put_bool("exclude_reblogs", exclude_reblogs)
  params.put_bool("only_media", only_media)
  params.put_bool("only_public", only_public)
  status_array_response(self.call(GetAccountStatuses(id), query=params))
}

///|
pub async fn Client::get_account_followers(
  self : Self,
  id : String,
  limit? : Int,
  max_id? : String,
  since_id? : String,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  accounts_response(
    self.call(
      GetAccountFollowers(id),
      query=page_params(limit?, max_id?, since_id?),
    ),
  )
}

///|
pub async fn Client::get_account_following(
  self : Self,
  id : String,
  limit? : Int,
  max_id? : String,
  since_id? : String,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  accounts_response(
    self.call(
      GetAccountFollowing(id),
      query=page_params(limit?, max_id?, since_id?),
    ),
  )
}

///|
pub async fn Client::lookup_account(
  self : Self,
  acct : String,
) -> @api.Response[@entity.Account] raise @api.MegalodonError {
  let params = @api.Params::new()
  params.put_string("acct", Some(acct))
  account_response(self.call(LookupAccount, query=params))
}

///|
pub async fn Client::search_account(
  self : Self,
  q : String,
  following? : Bool,
  resolve? : Bool,
  limit? : Int,
  max_id? : String,
  since_id? : String,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  let params = page_params(limit?, max_id?, since_id?)
  params.put_string("q", Some(q))
  params.put_bool("following", following)
  params.put_bool("resolve", resolve)
  accounts_response(self.call(SearchAccount, query=params))
}

///|
async fn Client::account_action(
  self : Self,
  endpoint : Endpoint,
  body? : Json = {},
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  object_response(self.call(endpoint, body=@api.Json(body)), "Relationship")
}

///|
pub async fn Client::follow_account(
  self : Self,
  id : String,
  reblogs? : Bool,
  notify? : Bool,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  let body : Map[String, Json] = Map([])
  if reblogs is Some(value) {
    body["reblogs"] = Json::boolean(value)
  }
  if notify is Some(value) {
    body["notify"] = Json::boolean(value)
  }
  self.account_action(FollowAccount(id), body=Json::object(body))
}

///|
pub async fn Client::unfollow_account(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  self.account_action(UnfollowAccount(id))
}

///|
pub async fn Client::block_account(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  self.account_action(BlockAccount(id))
}

///|
pub async fn Client::unblock_account(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  self.account_action(UnblockAccount(id))
}

///|
pub async fn Client::mute_account(
  self : Self,
  id : String,
  notifications? : Bool,
  duration? : Int64,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  let body : Map[String, Json] = Map([])
  if notifications is Some(value) {
    body["notifications"] = Json::boolean(value)
  }
  if duration is Some(value) {
    body["duration"] = Json::number(value.to_double())
  }
  self.account_action(MuteAccount(id), body=Json::object(body))
}

///|
pub async fn Client::unmute_account(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  self.account_action(UnmuteAccount(id))
}

///|
pub async fn Client::get_relationships(
  self : Self,
  ids : Array[String],
) -> @api.Response[Array[@entity.Relationship]] raise @api.MegalodonError {
  let params = @api.Params::new()
  params.put_strings("id[]", Some(ids))
  object_array_response(
    self.call(GetRelationships, query=params),
    "Relationship",
  )
}

///|
pub async fn Client::get_bookmarks(
  self : Self,
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  status_array_response(
    self.call(
      GetBookmarks,
      query=page_params(limit?, max_id?, since_id?, min_id?),
    ),
  )
}

///|
pub async fn Client::get_favourites(
  self : Self,
  limit? : Int,
  max_id? : String,
  min_id? : String,
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  status_array_response(
    self.call(
      GetFavourites,
      query=page_params(limit?, max_id?, since_id?=None, min_id?),
    ),
  )
}

///|
pub async fn Client::get_mutes(
  self : Self,
  limit? : Int,
  max_id? : String,
  min_id? : String,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  accounts_response(
    self.call(
      GetMutes,
      query=page_params(limit?, max_id?, since_id?=None, min_id?),
    ),
  )
}

///|
pub async fn Client::get_blocks(
  self : Self,
  limit? : Int,
  max_id? : String,
  min_id? : String,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  accounts_response(
    self.call(
      GetBlocks,
      query=page_params(limit?, max_id?, since_id?=None, min_id?),
    ),
  )
}
