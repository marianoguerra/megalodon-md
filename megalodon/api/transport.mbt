///|
/// An HTTP method supported by the Mastodon-compatible REST API.
pub(all) enum HttpMethod {
  Get
  Post
  Put
  Patch
  Delete
} derive(Eq, Debug)

///|
pub fn HttpMethod::to_string(self : Self) -> String {
  match self {
    Get => "GET"
    Post => "POST"
    Put => "PUT"
    Patch => "PATCH"
    Delete => "DELETE"
  }
}

///|
/// A fully encoded outbound request. Transports must not reinterpret `body`.
pub(all) struct HttpRequest {
  url : String
  http_method : HttpMethod
  headers : Map[String, String]
  body : Bytes
} derive(Eq, Debug)

///|
pub fn HttpRequest::body_text(self : Self) -> String {
  @utf8.decode_lossy(self.body[:])
}

///|
pub fn HttpRequest::content_length(self : Self) -> Int {
  self.body.length()
}

///|
pub(all) struct HttpResponse {
  status : Int
  /// Header names must be lower-cased by the transport.
  headers : Map[String, String]
  body : Bytes
} derive(Eq, Debug)

///|
pub fn HttpResponse::header(self : Self, name : String) -> String? {
  self.headers.get(name.to_lower())
}

///|
pub fn HttpResponse::body_text(self : Self) -> String {
  @utf8.decode_lossy(self.body[:])
}

///|
/// The portable seam between request construction and an HTTP implementation.
/// Implementations should translate runtime/network failures to
/// `RequestFailed`; status-code interpretation stays in the portable core.
pub(open) trait Transport {
  async fn send(Self, HttpRequest) -> HttpResponse
  fn describe(Self) -> String
}
