///|
/// The complete non-streaming, non-admin operation inventory from
/// `megalodon-rs/src/megalodon.rs` at the revision recorded in provenance.
pub(all) enum Endpoint {
  CreateApp
  FetchAccessToken
  RefreshAccessToken
  RevokeAccessToken
  VerifyAppCredentials
  RegisterAccount
  VerifyAccountCredentials
  UpdateCredentials
  GetAccount(String)
  GetAccountStatuses(String)
  GetAccountFavourites(String)
  SubscribeAccount(String)
  UnsubscribeAccount(String)
  GetAccountFollowers(String)
  GetAccountFollowing(String)
  GetAccountLists(String)
  GetIdentityProofs(String)
  FollowAccount(String)
  UnfollowAccount(String)
  BlockAccount(String)
  UnblockAccount(String)
  MuteAccount(String)
  UnmuteAccount(String)
  PinAccount(String)
  UnpinAccount(String)
  SetAccountNote(String)
  GetRelationships
  SearchAccount
  LookupAccount
  GetBookmarks
  GetFavourites
  GetMutes
  GetBlocks
  GetDomainBlocks
  BlockDomain
  UnblockDomain
  GetFilters
  GetFilter(String)
  CreateFilter
  UpdateFilter(String)
  DeleteFilter(String)
  Report
  GetFollowRequests
  AcceptFollowRequest(String)
  RejectFollowRequest(String)
  GetEndorsements
  GetFeaturedTags
  CreateFeaturedTag
  DeleteFeaturedTag(String)
  GetSuggestedTags
  GetPreferences
  GetFollowedTags
  GetSuggestions
  GetTag(String)
  FollowTag(String)
  UnfollowTag(String)
  PostStatus
  GetStatus(String)
  GetStatusSource(String)
  EditStatus(String)
  DeleteStatus(String)
  GetStatusContext(String)
  GetStatusRebloggedBy(String)
  GetStatusFavouritedBy(String)
  FavouriteStatus(String)
  UnfavouriteStatus(String)
  ReblogStatus(String)
  UnreblogStatus(String)
  BookmarkStatus(String)
  UnbookmarkStatus(String)
  MuteStatus(String)
  UnmuteStatus(String)
  PinStatus(String)
  UnpinStatus(String)
  UploadMedia
  GetMedia(String)
  UpdateMedia(String)
  GetPoll(String)
  VotePoll(String)
  GetScheduledStatuses
  GetScheduledStatus(String)
  ScheduleStatus(String)
  CancelScheduledStatus(String)
  GetPublicTimeline
  GetLocalTimeline
  GetTagTimeline(String)
  GetHomeTimeline
  GetListTimeline(String)
  GetConversationTimeline
  DeleteConversation(String)
  ReadConversation(String)
  GetLists
  GetList(String)
  CreateList
  UpdateList(String)
  DeleteList(String)
  GetAccountsInList(String)
  AddAccountsToList(String)
  DeleteAccountsFromList(String)
  GetMarkers
  SaveMarkers
  GetNotifications
  GetNotification(String)
  DismissNotifications
  DismissNotification(String)
  ReadNotifications
  SubscribePushNotification
  GetPushSubscription
  UpdatePushSubscription
  DeletePushSubscription
  Search
  GetInstance
  GetInstancePeers
  GetInstanceActivity
  GetInstanceTrends
  GetInstanceDirectory
  GetInstanceCustomEmojis
  GetInstanceAnnouncements
  DismissInstanceAnnouncement(String)
  AddReactionToAnnouncement(id~ : String, name~ : String)
  RemoveReactionFromAnnouncement(id~ : String, name~ : String)
  CreateEmojiReaction(id~ : String, emoji~ : String)
  DeleteEmojiReaction(id~ : String, emoji~ : String)
  GetEmojiReactions(String)
  GetEmojiReaction(id~ : String, emoji~ : String)
} derive(Eq, Debug)

///|
pub fn Endpoint::http_method(self : Self) -> @api.HttpMethod {
  match self {
    CreateApp
    | FetchAccessToken
    | RefreshAccessToken
    | RevokeAccessToken
    | RegisterAccount
    | FollowAccount(_)
    | UnfollowAccount(_)
    | SubscribeAccount(_)
    | UnsubscribeAccount(_)
    | BlockAccount(_)
    | UnblockAccount(_)
    | MuteAccount(_)
    | UnmuteAccount(_)
    | PinAccount(_)
    | UnpinAccount(_)
    | SetAccountNote(_)
    | BlockDomain
    | CreateFilter
    | Report
    | AcceptFollowRequest(_)
    | RejectFollowRequest(_)
    | CreateFeaturedTag
    | FollowTag(_)
    | UnfollowTag(_)
    | PostStatus
    | FavouriteStatus(_)
    | UnfavouriteStatus(_)
    | ReblogStatus(_)
    | UnreblogStatus(_)
    | BookmarkStatus(_)
    | UnbookmarkStatus(_)
    | MuteStatus(_)
    | UnmuteStatus(_)
    | PinStatus(_)
    | UnpinStatus(_)
    | UploadMedia
    | VotePoll(_)
    | ReadConversation(_)
    | CreateList
    | AddAccountsToList(_)
    | SaveMarkers
    | DismissNotifications
    | DismissNotification(_)
    | ReadNotifications
    | SubscribePushNotification
    | DismissInstanceAnnouncement(_)
    | AddReactionToAnnouncement(..)
    | CreateEmojiReaction(..) => @api.Post
    UpdateFilter(_)
    | EditStatus(_)
    | UpdateMedia(_)
    | ScheduleStatus(_)
    | UpdateList(_)
    | UpdatePushSubscription => @api.Put
    DeleteStatus(_)
    | DeleteFilter(_)
    | DeleteFeaturedTag(_)
    | CancelScheduledStatus(_)
    | DeleteConversation(_)
    | DeleteList(_)
    | DeleteAccountsFromList(_)
    | DeletePushSubscription
    | RemoveReactionFromAnnouncement(..)
    | DeleteEmojiReaction(..)
    | UnblockDomain => @api.Delete
    UpdateCredentials => @api.Patch
    _ => @api.Get
  }
}

///|
pub fn Endpoint::path(self : Self) -> String {
  match self {
    CreateApp => "/api/v1/apps"
    FetchAccessToken | RefreshAccessToken => "/oauth/token"
    RevokeAccessToken => "/oauth/revoke"
    VerifyAppCredentials => "/api/v1/apps/verify_credentials"
    RegisterAccount => "/api/v1/accounts"
    VerifyAccountCredentials => "/api/v1/accounts/verify_credentials"
    UpdateCredentials => "/api/v1/accounts/update_credentials"
    GetAccount(id) => "/api/v1/accounts/\{id}"
    GetAccountStatuses(id) => "/api/v1/accounts/\{id}/statuses"
    GetAccountFavourites(id) => "/api/v1/accounts/\{id}/favourites"
    SubscribeAccount(id) | FollowAccount(id) => "/api/v1/accounts/\{id}/follow"
    UnsubscribeAccount(id) | UnfollowAccount(id) =>
      "/api/v1/accounts/\{id}/unfollow"
    GetAccountFollowers(id) => "/api/v1/accounts/\{id}/followers"
    GetAccountFollowing(id) => "/api/v1/accounts/\{id}/following"
    GetAccountLists(id) => "/api/v1/accounts/\{id}/lists"
    GetIdentityProofs(id) => "/api/v1/accounts/\{id}/identity_proofs"
    BlockAccount(id) => "/api/v1/accounts/\{id}/block"
    UnblockAccount(id) => "/api/v1/accounts/\{id}/unblock"
    MuteAccount(id) => "/api/v1/accounts/\{id}/mute"
    UnmuteAccount(id) => "/api/v1/accounts/\{id}/unmute"
    PinAccount(id) => "/api/v1/accounts/\{id}/pin"
    UnpinAccount(id) => "/api/v1/accounts/\{id}/unpin"
    SetAccountNote(id) => "/api/v1/accounts/\{id}/note"
    GetRelationships => "/api/v1/accounts/relationships"
    SearchAccount => "/api/v1/accounts/search"
    LookupAccount => "/api/v1/accounts/lookup"
    GetBookmarks => "/api/v1/bookmarks"
    GetFavourites => "/api/v1/favourites"
    GetMutes => "/api/v1/mutes"
    GetBlocks => "/api/v1/blocks"
    GetDomainBlocks | BlockDomain | UnblockDomain => "/api/v1/domain_blocks"
    GetFilters | CreateFilter => "/api/v1/filters"
    GetFilter(id) | UpdateFilter(id) | DeleteFilter(id) =>
      "/api/v1/filters/\{id}"
    Report => "/api/v1/reports"
    GetFollowRequests => "/api/v1/follow_requests"
    AcceptFollowRequest(id) => "/api/v1/follow_requests/\{id}/authorize"
    RejectFollowRequest(id) => "/api/v1/follow_requests/\{id}/reject"
    GetEndorsements => "/api/v1/endorsements"
    GetFeaturedTags | CreateFeaturedTag => "/api/v1/featured_tags"
    DeleteFeaturedTag(id) => "/api/v1/featured_tags/\{id}"
    GetSuggestedTags => "/api/v1/featured_tags/suggestions"
    GetPreferences => "/api/v1/preferences"
    GetFollowedTags => "/api/v1/followed_tags"
    GetSuggestions => "/api/v1/suggestions"
    GetTag(id) => "/api/v1/tags/\{id}"
    FollowTag(id) => "/api/v1/tags/\{id}/follow"
    UnfollowTag(id) => "/api/v1/tags/\{id}/unfollow"
    PostStatus => "/api/v1/statuses"
    GetStatus(id) | EditStatus(id) | DeleteStatus(id) =>
      "/api/v1/statuses/\{id}"
    GetStatusSource(id) => "/api/v1/statuses/\{id}/source"
    GetStatusContext(id) => "/api/v1/statuses/\{id}/context"
    GetStatusRebloggedBy(id) => "/api/v1/statuses/\{id}/reblogged_by"
    GetStatusFavouritedBy(id) => "/api/v1/statuses/\{id}/favourited_by"
    FavouriteStatus(id) => "/api/v1/statuses/\{id}/favourite"
    UnfavouriteStatus(id) => "/api/v1/statuses/\{id}/unfavourite"
    ReblogStatus(id) => "/api/v1/statuses/\{id}/reblog"
    UnreblogStatus(id) => "/api/v1/statuses/\{id}/unreblog"
    BookmarkStatus(id) => "/api/v1/statuses/\{id}/bookmark"
    UnbookmarkStatus(id) => "/api/v1/statuses/\{id}/unbookmark"
    MuteStatus(id) => "/api/v1/statuses/\{id}/mute"
    UnmuteStatus(id) => "/api/v1/statuses/\{id}/unmute"
    PinStatus(id) => "/api/v1/statuses/\{id}/pin"
    UnpinStatus(id) => "/api/v1/statuses/\{id}/unpin"
    UploadMedia => "/api/v2/media"
    GetMedia(id) | UpdateMedia(id) => "/api/v1/media/\{id}"
    GetPoll(id) => "/api/v1/polls/\{id}"
    VotePoll(id) => "/api/v1/polls/\{id}/votes"
    GetScheduledStatuses => "/api/v1/scheduled_statuses"
    GetScheduledStatus(id) | ScheduleStatus(id) | CancelScheduledStatus(id) =>
      "/api/v1/scheduled_statuses/\{id}"
    GetPublicTimeline | GetLocalTimeline => "/api/v1/timelines/public"
    GetTagTimeline(tag) => "/api/v1/timelines/tag/\{@api.percent_encode(tag)}"
    GetHomeTimeline => "/api/v1/timelines/home"
    GetListTimeline(id) => "/api/v1/timelines/list/\{id}"
    GetConversationTimeline => "/api/v1/conversations"
    DeleteConversation(id) => "/api/v1/conversations/\{id}"
    ReadConversation(id) => "/api/v1/conversations/\{id}/read"
    GetLists | CreateList => "/api/v1/lists"
    GetList(id) | UpdateList(id) | DeleteList(id) => "/api/v1/lists/\{id}"
    GetAccountsInList(id)
    | AddAccountsToList(id)
    | DeleteAccountsFromList(id) => "/api/v1/lists/\{id}/accounts"
    GetMarkers | SaveMarkers => "/api/v1/markers"
    GetNotifications => "/api/v1/notifications"
    GetNotification(id) => "/api/v1/notifications/\{id}"
    DismissNotifications => "/api/v1/notifications/clear"
    DismissNotification(id) => "/api/v1/notifications/\{id}/dismiss"
    ReadNotifications => "/api/v1/notifications/read"
    SubscribePushNotification
    | GetPushSubscription
    | UpdatePushSubscription
    | DeletePushSubscription => "/api/v1/push/subscription"
    Search => "/api/v2/search"
    GetInstance => "/api/v2/instance"
    GetInstancePeers => "/api/v1/instance/peers"
    GetInstanceActivity => "/api/v1/instance/activity"
    GetInstanceTrends => "/api/v1/trends"
    GetInstanceDirectory => "/api/v1/directory"
    GetInstanceCustomEmojis => "/api/v1/custom_emojis"
    GetInstanceAnnouncements => "/api/v1/announcements"
    DismissInstanceAnnouncement(id) => "/api/v1/announcements/\{id}/dismiss"
    AddReactionToAnnouncement(id~, name~)
    | RemoveReactionFromAnnouncement(id~, name~) =>
      "/api/v1/announcements/\{id}/reactions/\{@api.percent_encode(name)}"
    CreateEmojiReaction(id~, emoji~) | DeleteEmojiReaction(id~, emoji~) =>
      "/api/v1/pleroma/statuses/\{id}/reactions/\{@api.percent_encode(emoji)}"
    GetEmojiReactions(id) => "/api/v1/pleroma/statuses/\{id}/reactions"
    GetEmojiReaction(id~, emoji~) =>
      "/api/v1/pleroma/statuses/\{id}/reactions/\{@api.percent_encode(emoji)}"
  }
}
