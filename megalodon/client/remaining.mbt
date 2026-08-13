// Named wrappers for the remainder of the frozen non-streaming Rust trait.
// Servers add fields frequently, so less stable responses use EntityObject:
// callers get shape validation plus lossless access to the original JSON.

///|
pub async fn Client::verify_app_credentials(
  self : Self,
) -> @api.Response[@entity.Application] raise @api.MegalodonError {
  object_response(self.call(VerifyAppCredentials), "Application")
}

///|
pub async fn Client::register_account(
  self : Self,
  input : Json,
) -> @api.Response[@entity.Token] raise @api.MegalodonError {
  object_response(self.call(RegisterAccount, body=@api.Json(input)), "Token")
}

///|
pub async fn Client::update_credentials(
  self : Self,
  body : @api.RequestBody,
) -> @api.Response[@entity.Account] raise @api.MegalodonError {
  account_response(self.call(UpdateCredentials, body~))
}

///|
pub async fn Client::get_account_favourites(
  self : Self,
  id : String,
  limit? : Int,
  max_id? : String,
  min_id? : String,
) -> @api.Response[Array[@entity.Status]] raise @api.MegalodonError {
  status_array_response(
    self.call(
      GetAccountFavourites(id),
      query=page_params(limit?, max_id?, since_id?=None, min_id?),
    ),
  )
}

///|
pub async fn Client::subscribe_account(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  object_response(
    self.call(SubscribeAccount(id), body=@api.Json({ "notify": true })),
    "Relationship",
  )
}

///|
pub async fn Client::unsubscribe_account(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  object_response(
    self.call(UnsubscribeAccount(id), body=@api.Json({ "notify": false })),
    "Relationship",
  )
}

///|
pub async fn Client::get_account_lists(
  self : Self,
  id : String,
) -> @api.Response[Array[@entity.List]] raise @api.MegalodonError {
  object_array_response(self.call(GetAccountLists(id)), "List")
}

///|
pub async fn Client::get_identity_proofs(
  self : Self,
  id : String,
) -> @api.Response[Array[@entity.IdentityProof]] raise @api.MegalodonError {
  object_array_response(self.call(GetIdentityProofs(id)), "IdentityProof")
}

///|
pub async fn Client::pin_account(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  object_response(self.call(PinAccount(id), body=@api.Json({})), "Relationship")
}

///|
pub async fn Client::unpin_account(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  object_response(
    self.call(UnpinAccount(id), body=@api.Json({})),
    "Relationship",
  )
}

///|
pub async fn Client::set_account_note(
  self : Self,
  id : String,
  comment : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  object_response(
    self.call(SetAccountNote(id), body=@api.Json({ "comment": comment })),
    "Relationship",
  )
}

///|
pub async fn Client::get_domain_blocks(
  self : Self,
  limit? : Int,
  max_id? : String,
) -> @api.Response[Array[String]] raise @api.MegalodonError {
  decode_response(
    self.call(GetDomainBlocks, query=page_params(limit?, max_id?)),
    json => {
      guard json is Array(values) else {
        raise @api.InvalidEntity(
          entity="DomainBlocks",
          detail="expected an array",
        )
      }
      let domains = []
      for value in values {
        guard value is String(domain) else {
          raise @api.InvalidEntity(
            entity="DomainBlocks",
            detail="expected strings",
          )
        }
        domains.push(domain)
      }
      domains
    },
  )
}

///|
pub async fn Client::block_domain(
  self : Self,
  domain : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(BlockDomain, body=@api.Json({ "domain": domain }))
}

///|
pub async fn Client::unblock_domain(
  self : Self,
  domain : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(UnblockDomain, body=@api.Json({ "domain": domain }))
}

///|
pub async fn Client::get_filters(
  self : Self,
) -> @api.Response[Array[@entity.Filter]] raise @api.MegalodonError {
  object_array_response(self.call(GetFilters), "Filter")
}

///|
pub async fn Client::get_filter(
  self : Self,
  id : String,
) -> @api.Response[@entity.Filter] raise @api.MegalodonError {
  object_response(self.call(GetFilter(id)), "Filter")
}

///|
pub async fn Client::create_filter(
  self : Self,
  input : Json,
) -> @api.Response[@entity.Filter] raise @api.MegalodonError {
  object_response(self.call(CreateFilter, body=@api.Json(input)), "Filter")
}

///|
pub async fn Client::update_filter(
  self : Self,
  id : String,
  input : Json,
) -> @api.Response[@entity.Filter] raise @api.MegalodonError {
  object_response(self.call(UpdateFilter(id), body=@api.Json(input)), "Filter")
}

///|
pub async fn Client::delete_filter(
  self : Self,
  id : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(DeleteFilter(id))
}

///|
pub async fn Client::report(
  self : Self,
  input : Json,
) -> @api.Response[@entity.Report] raise @api.MegalodonError {
  object_response(self.call(Report, body=@api.Json(input)), "Report")
}

///|
pub async fn Client::get_follow_requests(
  self : Self,
  limit? : Int,
  max_id? : String,
) -> @api.Response[Array[@entity.FollowRequest]] raise @api.MegalodonError {
  object_array_response(
    self.call(GetFollowRequests, query=page_params(limit?, max_id?)),
    "FollowRequest",
  )
}

///|
pub async fn Client::accept_follow_request(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  object_response(
    self.call(AcceptFollowRequest(id), body=@api.Json({})),
    "Relationship",
  )
}

///|
pub async fn Client::reject_follow_request(
  self : Self,
  id : String,
) -> @api.Response[@entity.Relationship] raise @api.MegalodonError {
  object_response(
    self.call(RejectFollowRequest(id), body=@api.Json({})),
    "Relationship",
  )
}

///|
pub async fn Client::get_endorsements(
  self : Self,
  limit? : Int,
  max_id? : String,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  accounts_response(
    self.call(GetEndorsements, query=page_params(limit?, max_id?)),
  )
}

///|
pub async fn Client::get_featured_tags(
  self : Self,
) -> @api.Response[Array[@entity.FeaturedTag]] raise @api.MegalodonError {
  object_array_response(self.call(GetFeaturedTags), "FeaturedTag")
}

///|
pub async fn Client::create_featured_tag(
  self : Self,
  name : String,
) -> @api.Response[@entity.FeaturedTag] raise @api.MegalodonError {
  object_response(
    self.call(CreateFeaturedTag, body=@api.Json({ "name": name })),
    "FeaturedTag",
  )
}

///|
pub async fn Client::delete_featured_tag(
  self : Self,
  id : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(DeleteFeaturedTag(id))
}

///|
pub async fn Client::get_suggested_tags(
  self : Self,
) -> @api.Response[Array[@entity.FeaturedTag]] raise @api.MegalodonError {
  object_array_response(self.call(GetSuggestedTags), "FeaturedTag")
}

///|
pub async fn Client::get_preferences(
  self : Self,
) -> @api.Response[@entity.Preferences] raise @api.MegalodonError {
  decode_response(self.call(GetPreferences), @entity.Preferences::from_json)
}

///|
pub async fn Client::get_followed_tags(
  self : Self,
) -> @api.Response[Array[@entity.Tag]] raise @api.MegalodonError {
  object_array_response(self.call(GetFollowedTags), "Tag")
}

///|
pub async fn Client::get_suggestions(
  self : Self,
  limit? : Int,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  let query = @api.Params::new()
  query.put_int("limit", limit.map(value => value.to_int64()))
  accounts_response(self.call(GetSuggestions, query~))
}

///|
pub async fn Client::get_tag(
  self : Self,
  id : String,
) -> @api.Response[@entity.Tag] raise @api.MegalodonError {
  object_response(self.call(GetTag(id)), "Tag")
}

///|
pub async fn Client::follow_tag(
  self : Self,
  id : String,
) -> @api.Response[@entity.Tag] raise @api.MegalodonError {
  object_response(self.call(FollowTag(id), body=@api.Json({})), "Tag")
}

///|
pub async fn Client::unfollow_tag(
  self : Self,
  id : String,
) -> @api.Response[@entity.Tag] raise @api.MegalodonError {
  object_response(self.call(UnfollowTag(id), body=@api.Json({})), "Tag")
}

///|
pub async fn Client::get_status_source(
  self : Self,
  id : String,
) -> @api.Response[@entity.StatusSource] raise @api.MegalodonError {
  object_response(self.call(GetStatusSource(id)), "StatusSource")
}

///|
pub async fn Client::get_status_context(
  self : Self,
  id : String,
) -> @api.Response[@entity.Context] raise @api.MegalodonError {
  object_response(self.call(GetStatusContext(id)), "Context")
}

///|
pub async fn Client::get_status_reblogged_by(
  self : Self,
  id : String,
  limit? : Int,
  max_id? : String,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  accounts_response(
    self.call(GetStatusRebloggedBy(id), query=page_params(limit?, max_id?)),
  )
}

///|
pub async fn Client::get_status_favourited_by(
  self : Self,
  id : String,
  limit? : Int,
  max_id? : String,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  accounts_response(
    self.call(GetStatusFavouritedBy(id), query=page_params(limit?, max_id?)),
  )
}

///|
pub async fn Client::update_media(
  self : Self,
  id : String,
  description? : String,
  focus? : String,
) -> @api.Response[@entity.Attachment] raise @api.MegalodonError {
  let input : Map[String, Json] = Map([])
  if description is Some(value) {
    input["description"] = Json::string(value)
  }
  if focus is Some(value) {
    input["focus"] = Json::string(value)
  }
  decode_response(
    self.call(UpdateMedia(id), body=@api.Json(Json::object(input))),
    @entity.Attachment::from_json,
  )
}

///|
pub async fn Client::get_scheduled_statuses(
  self : Self,
  limit? : Int,
  max_id? : String,
) -> @api.Response[Array[@entity.ScheduledStatus]] raise @api.MegalodonError {
  object_array_response(
    self.call(GetScheduledStatuses, query=page_params(limit?, max_id?)),
    "ScheduledStatus",
  )
}

///|
pub async fn Client::get_scheduled_status(
  self : Self,
  id : String,
) -> @api.Response[@entity.ScheduledStatus] raise @api.MegalodonError {
  object_response(self.call(GetScheduledStatus(id)), "ScheduledStatus")
}

///|
pub async fn Client::schedule_status(
  self : Self,
  id : String,
  scheduled_at : String,
) -> @api.Response[@entity.ScheduledStatus] raise @api.MegalodonError {
  object_response(
    self.call(
      ScheduleStatus(id),
      body=@api.Json({ "scheduled_at": scheduled_at }),
    ),
    "ScheduledStatus",
  )
}

///|
pub async fn Client::cancel_scheduled_status(
  self : Self,
  id : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(CancelScheduledStatus(id))
}

///|
pub async fn Client::get_conversation_timeline(
  self : Self,
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
) -> @api.Response[Array[@entity.Conversation]] raise @api.MegalodonError {
  object_array_response(
    self.call(
      GetConversationTimeline,
      query=page_params(limit?, max_id?, since_id?, min_id?),
    ),
    "Conversation",
  )
}

///|
pub async fn Client::delete_conversation(
  self : Self,
  id : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(DeleteConversation(id))
}

///|
pub async fn Client::read_conversation(
  self : Self,
  id : String,
) -> @api.Response[@entity.Conversation] raise @api.MegalodonError {
  object_response(
    self.call(ReadConversation(id), body=@api.Json({})),
    "Conversation",
  )
}

///|
pub async fn Client::update_list(
  self : Self,
  id : String,
  title : String,
) -> @api.Response[@entity.List] raise @api.MegalodonError {
  object_response(
    self.call(UpdateList(id), body=@api.Json({ "title": title })),
    "List",
  )
}

///|
pub async fn Client::delete_list(
  self : Self,
  id : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(DeleteList(id))
}

///|
pub async fn Client::get_accounts_in_list(
  self : Self,
  id : String,
  limit? : Int,
  max_id? : String,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  accounts_response(
    self.call(GetAccountsInList(id), query=page_params(limit?, max_id?)),
  )
}

///|
pub async fn Client::add_accounts_to_list(
  self : Self,
  id : String,
  account_ids : Array[String],
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(
    AddAccountsToList(id),
    body=@api.Json({ "account_ids": account_ids }),
  )
}

///|
pub async fn Client::delete_accounts_from_list(
  self : Self,
  id : String,
  account_ids : Array[String],
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(
    DeleteAccountsFromList(id),
    body=@api.Json({ "account_ids": account_ids }),
  )
}

///|
pub async fn Client::get_markers(
  self : Self,
  timelines : Array[String],
) -> @api.Response[@entity.Marker] raise @api.MegalodonError {
  let query = @api.Params::new()
  query.put_strings("timeline[]", Some(timelines))
  decode_response(self.call(GetMarkers, query~), @entity.Marker::from_json)
}

///|
pub async fn Client::save_markers(
  self : Self,
  markers : Json,
) -> @api.Response[@entity.Marker] raise @api.MegalodonError {
  decode_response(
    self.call(SaveMarkers, body=@api.Json(markers)),
    @entity.Marker::from_json,
  )
}

///|
pub async fn Client::read_notifications(
  self : Self,
  input : Json,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(ReadNotifications, body=@api.Json(input))
}

///|
pub async fn Client::subscribe_push_notification(
  self : Self,
  input : Json,
) -> @api.Response[@entity.PushSubscription] raise @api.MegalodonError {
  object_response(
    self.call(SubscribePushNotification, body=@api.Json(input)),
    "PushSubscription",
  )
}

///|
pub async fn Client::get_push_subscription(
  self : Self,
) -> @api.Response[@entity.PushSubscription] raise @api.MegalodonError {
  object_response(self.call(GetPushSubscription), "PushSubscription")
}

///|
pub async fn Client::update_push_subscription(
  self : Self,
  input : Json,
) -> @api.Response[@entity.PushSubscription] raise @api.MegalodonError {
  object_response(
    self.call(UpdatePushSubscription, body=@api.Json(input)),
    "PushSubscription",
  )
}

///|
pub async fn Client::delete_push_subscription(
  self : Self,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(DeletePushSubscription)
}

///|
pub async fn Client::get_instance_activity(
  self : Self,
) -> @api.Response[Array[@entity.Activity]] raise @api.MegalodonError {
  object_array_response(self.call(GetInstanceActivity), "Activity")
}

///|
pub async fn Client::get_instance_trends(
  self : Self,
  limit? : Int,
) -> @api.Response[Array[@entity.Tag]] raise @api.MegalodonError {
  let query = @api.Params::new()
  query.put_int("limit", limit.map(value => value.to_int64()))
  object_array_response(self.call(GetInstanceTrends, query~), "Tag")
}

///|
pub async fn Client::get_instance_directory(
  self : Self,
  limit? : Int,
  offset? : Int64,
  order? : DirectoryOrder,
  local_only? : Bool,
) -> @api.Response[Array[@entity.Account]] raise @api.MegalodonError {
  let query = @api.Params::new()
  query.put_int("limit", limit.map(value => value.to_int64()))
  query.put_int("offset", offset)
  query.put_string("order", order.map(value => value.to_string()))
  query.put_bool("local", local_only)
  accounts_response(self.call(GetInstanceDirectory, query~))
}

///|
pub async fn Client::get_instance_custom_emojis(
  self : Self,
) -> @api.Response[Array[@entity.Emoji]] raise @api.MegalodonError {
  object_array_response(self.call(GetInstanceCustomEmojis), "Emoji")
}

///|
pub async fn Client::get_instance_announcements(
  self : Self,
  with_dismissed? : Bool,
) -> @api.Response[Array[@entity.Announcement]] raise @api.MegalodonError {
  let query = @api.Params::new()
  query.put_bool("with_dismissed", with_dismissed)
  object_array_response(
    self.call(GetInstanceAnnouncements, query~),
    "Announcement",
  )
}

///|
pub async fn Client::dismiss_instance_announcement(
  self : Self,
  id : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(DismissInstanceAnnouncement(id), body=@api.Json({}))
}

///|
pub async fn Client::add_reaction_to_announcement(
  self : Self,
  id : String,
  name : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(AddReactionToAnnouncement(id~, name~), body=@api.Json({}))
}

///|
pub async fn Client::remove_reaction_from_announcement(
  self : Self,
  id : String,
  name : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(RemoveReactionFromAnnouncement(id~, name~))
}

///|
pub async fn Client::create_emoji_reaction(
  self : Self,
  id : String,
  emoji : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  status_response(
    self.call(CreateEmojiReaction(id~, emoji~), body=@api.Json({})),
  )
}

///|
pub async fn Client::delete_emoji_reaction(
  self : Self,
  id : String,
  emoji : String,
) -> @api.Response[@entity.Status] raise @api.MegalodonError {
  status_response(self.call(DeleteEmojiReaction(id~, emoji~)))
}

///|
pub async fn Client::get_emoji_reactions(
  self : Self,
  id : String,
) -> @api.Response[Array[@entity.Reaction]] raise @api.MegalodonError {
  object_array_response(self.call(GetEmojiReactions(id)), "Reaction")
}

///|
pub async fn Client::get_emoji_reaction(
  self : Self,
  id : String,
  emoji : String,
) -> @api.Response[@entity.Reaction] raise @api.MegalodonError {
  object_response(self.call(GetEmojiReaction(id~, emoji~)), "Reaction")
}
