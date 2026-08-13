///|
pub using @api {
  type HttpMethod,
  type HttpRequest,
  type HttpResponse,
  type ParamValue,
  type Params,
  type RequestBody,
  type MultipartBody,
  type Pagination,
  type Response,
  type MegalodonError,
  trait Transport,
}

///|
pub using @client {
  type Client,
  type Endpoint,
  type ServerSoftware,
  type PollOptions,
  type SearchType,
  type DirectoryOrder,
}

///|
pub using @entity {
  type Account,
  type Activity,
  type Announcement,
  type Application,
  type AsyncAttachment,
  type Attachment,
  type AttachmentType,
  type Card,
  type Context,
  type Conversation,
  type Emoji,
  type ExpandMedia,
  type FeaturedTag,
  type Field,
  type Filter,
  type FilterContext,
  type FollowRequest,
  type History,
  type IdentityProof,
  type Instance,
  type List,
  type Marker,
  type MarkerEntry,
  type Mention,
  type Notification,
  type NotificationType,
  type Poll,
  type PollOption,
  type Preferences,
  type PushSubscription,
  type Quote,
  type QuoteApproval,
  type QuoteState,
  type QuotedStatus,
  type Reaction,
  type Relationship,
  type Report,
  type Results,
  type Role,
  type ScheduledStatus,
  type ShallowQuote,
  type Source,
  type Stats,
  type Status,
  type StatusParams,
  type StatusSource,
  type StatusVisibility,
  type Tag,
  type Token,
  type UploadMedia,
  type URLs,
}

///|
pub using @oauth {type AppData, type TokenData}

///|
pub fn generator(
  transport : &@api.Transport,
  software : @client.ServerSoftware,
  base_url : String,
  access_token? : String,
  user_agent? : String = @api.USER_AGENT,
) -> @client.Client {
  @client.Client::new(transport, software, base_url, access_token?, user_agent~)
}

///|
pub async fn detector(
  transport : &@api.Transport,
  base_url : String,
) -> @client.ServerSoftware raise @api.MegalodonError {
  @detector.detect(transport, base_url)
}
