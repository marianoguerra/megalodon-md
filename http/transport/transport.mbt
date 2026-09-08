///|
/// Native HTTP implementation of `@api.Transport`.
///
/// A fresh connection is used for each request. This keeps the adapter small,
/// makes concurrent calls independent, and leaves connection pooling as a
/// possible future transport without changing the portable client API.
pub struct HttpTransport {
  description : String
  trust : @tls.TrustedRoot?
}

///|
/// `trust` can select a custom CA file or disable verification for local tests.
/// Production callers should normally leave it unset so system roots are used.
pub fn HttpTransport::new(
  description? : String = "native HTTP",
  trust? : @tls.TrustedRoot,
) -> HttpTransport {
  { description, trust, }
}

///|
pub impl @api.Transport for HttpTransport with fn describe(self) {
  self.description
}

///|
pub impl @api.Transport for HttpTransport with fn send(self, request) {
  if self.trust is None &&
    (
      request.http_method == @api.Get ||
      request.http_method == @api.Post ||
      request.http_method == @api.Put
    ) {
    return self.send_convenience(request)
  }
  let (origin, path) = split_url(request.url)
  let headers : Map[@http.CaseInsensitiveString, String] = Map([])
  for name, value in request.headers {
    // The async HTTP client owns framing headers. Supplying a stale length is
    // especially dangerous for UTF-8 and multipart request bodies.
    if name.to_lower() != "content-length" {
      headers[@http.CaseInsensitiveString(name)] = value
    }
  }
  if request.body.length() > 0 {
    headers[@http.CaseInsensitiveString("content-length")] = request.body
      .length()
      .to_string()
  }
  let client = @http.Client(origin, trust?=self.trust) catch {
    e => raise @api.RequestFailed("\{self.description}: \{e}")
  }
  try {
    client.request(
      to_native_method(request.http_method),
      path,
      extra_headers=headers,
    )
    if request.body.length() > 0 {
      client.write(request.body)
    }
    let response = client.end_request()
    let body = client.read_all().binary()
    let response_headers : Map[String, String] = Map([])
    for name, value in response.headers {
      response_headers[name.0.to_lower()] = value
    }
    client.close()
    { status: response.code, headers: response_headers, body, }
  } catch {
    e => {
      client.close()
      raise @api.RequestFailed("\{self.description}: \{e}")
    }
  }
}

///|
/// Use the async HTTP library's redirect- and connection-lifecycle-aware
/// helpers for the common verbs. Custom trust roots and verbs without a helper
/// continue through the explicit client path above.
async fn HttpTransport::send_convenience(
  self : Self,
  request : @api.HttpRequest,
) -> @api.HttpResponse {
  let headers : Map[@http.CaseInsensitiveString, String] = Map([])
  for name, value in request.headers {
    if name.to_lower() != "content-length" {
      headers[@http.CaseInsensitiveString(name)] = value
    }
  }
  let (response, body) = try {
    match request.http_method {
      Get => @http.get(request.url, headers~)
      Post => @http.post(request.url, request.body, headers~)
      Put => @http.put(request.url, request.body, headers~)
      _ => raise @api.InvalidRequest("no convenience helper for this verb")
    }
  } catch {
    e => raise @api.RequestFailed("\{self.description}: \{e}")
  }
  let response_headers : Map[String, String] = Map([])
  for name, value in response.headers {
    response_headers[name.0.to_lower()] = value
  }
  { status: response.code, headers: response_headers, body: body.binary(), }
}

///|
pub fn split_url(url : String) -> (String, String) raise @api.MegalodonError {
  if !url.has_prefix("http://") && !url.has_prefix("https://") {
    raise @api.InvalidRequest("unsupported HTTP URL scheme: \{url}")
  }
  guard url.find("://") is Some(scheme_end) else {
    raise @api.InvalidRequest("HTTP transport requires an absolute URL: \{url}")
  }
  let authority_start = scheme_end + 3
  guard authority_start < url.length() else {
    raise @api.InvalidRequest("URL has no authority: \{url}")
  }
  match url[authority_start:].find("/") {
    Some(index) => {
      let boundary = authority_start + index
      (url[:boundary].to_owned(), url[boundary:].to_owned())
    }
    None => (url, "/")
  }
}

///|
fn to_native_method(request_method : @api.HttpMethod) -> @http.RequestMethod {
  match request_method {
    Get => Get
    Post => Post
    Put => Put
    Patch => Patch
    Delete => Delete
  }
}
