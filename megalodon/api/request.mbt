///|
pub const USER_AGENT : String = "marianoguerra-megalodon-mb/0.1.0"

///|
pub(all) enum RequestBody {
  Empty
  Json(Json)
  Form(Params)
  Raw(bytes~ : Bytes, content_type~ : String)
} derive(Eq, Debug)

///|
pub fn build_request(
  base_url : String,
  path : String,
  http_method : HttpMethod,
  query? : Params = Params::new(),
  body? : RequestBody = Empty,
  access_token? : String,
  user_agent? : String = USER_AGENT,
  extra_headers? : Map[String, String] = Map([]),
) -> HttpRequest {
  let origin = if base_url.has_suffix("/") {
    base_url[:base_url.length() - 1].to_owned()
  } else {
    base_url
  }
  let encoded_query = query.encode()
  let url = if encoded_query == "" {
    "\{origin}\{path}"
  } else {
    "\{origin}\{path}?\{encoded_query}"
  }
  let headers : Map[String, String] = Map([])
  headers["accept"] = "application/json"
  headers["user-agent"] = user_agent
  if access_token is Some(token) {
    headers["authorization"] = "Bearer \{token}"
  }
  let bytes = match body {
    Empty => b""
    Json(value) => {
      headers["content-type"] = "application/json"
      @utf8.encode(value.stringify())
    }
    Form(params) => {
      headers["content-type"] = "application/x-www-form-urlencoded"
      @utf8.encode(params.encode())
    }
    Raw(bytes~, content_type~) => {
      headers["content-type"] = content_type
      bytes
    }
  }
  if bytes.length() > 0 {
    headers["content-length"] = bytes.length().to_string()
  }
  for name, value in extra_headers {
    headers[name.to_lower()] = value
  }
  { url, http_method, headers, body: bytes }
}

///|
pub fn interpret(
  response : HttpResponse,
) -> Response[Json] raise MegalodonError {
  if response.status == 206 {
    raise PartialContent(headers=response.headers)
  }
  if response.status < 200 || response.status >= 300 {
    raise HttpStatus(
      status=response.status,
      body=response.body_text(),
      headers=response.headers,
    )
  }
  let value = if response.body.length() == 0 {
    Json::null()
  } else {
    @json.parse(response.body_text()) catch {
      error => raise InvalidJson(error.to_string())
    }
  }
  {
    data: value,
    status: response.status,
    headers: response.headers,
    pagination: pagination_from_headers(response.headers),
  }
}
