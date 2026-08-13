///|
pub(all) enum ServerSoftware {
  Mastodon
  Pleroma
  Friendica
  Firefish
  GoToSocial
  Pixelfed
  Akkoma
  Hometown
  Iceshrimp
  Unknown(String)
} derive(Eq, Debug)

///|
pub fn ServerSoftware::parse(value : String) -> ServerSoftware {
  match value.to_lower() {
    "mastodon" => Mastodon
    "pleroma" => Pleroma
    "friendica" => Friendica
    "firefish" | "calckey" => Firefish
    "gotosocial" => GoToSocial
    "pixelfed" => Pixelfed
    "akkoma" => Akkoma
    "hometown" => Hometown
    "iceshrimp" => Iceshrimp
    _ => Unknown(value)
  }
}

///|
pub fn ServerSoftware::to_string(self : Self) -> String {
  match self {
    Mastodon => "mastodon"
    Pleroma => "pleroma"
    Friendica => "friendica"
    Firefish => "firefish"
    GoToSocial => "gotosocial"
    Pixelfed => "pixelfed"
    Akkoma => "akkoma"
    Hometown => "hometown"
    Iceshrimp => "iceshrimp"
    Unknown(value) => value
  }
}

///|
pub struct Client {
  transport : &@api.Transport
  base_url : String
  software : ServerSoftware
  access_token : String?
  user_agent : String
  extra_headers : Map[String, String]
}

///|
pub fn Client::new(
  transport : &@api.Transport,
  software : ServerSoftware,
  base_url : String,
  access_token? : String,
  user_agent? : String = @api.USER_AGENT,
  extra_headers? : Map[String, String] = Map([]),
) -> Client {
  { transport, base_url, software, access_token, user_agent, extra_headers }
}

///|
pub fn Client::software(self : Self) -> ServerSoftware {
  self.software
}

///|
pub fn Client::base_url(self : Self) -> String {
  self.base_url
}

///|
/// The complete REST escape hatch. `Endpoint` inventories every operation in
/// the reference interface; query/body encoding remains explicit for forward
/// compatibility with server extensions.
pub async fn Client::call(
  self : Self,
  endpoint : Endpoint,
  query? : @api.Params = @api.Params::new(),
  body? : @api.RequestBody = @api.Empty,
) -> @api.Response[Json] raise @api.MegalodonError {
  let request = @api.build_request(
    self.base_url,
    endpoint.path(),
    endpoint.http_method(),
    query~,
    body~,
    access_token?=self.access_token,
    user_agent=self.user_agent,
    extra_headers=self.extra_headers,
  )
  let response = self.transport.send(request) catch {
    error => raise @api.to_megalodon_error(error)
  }
  @api.interpret(response)
}

///|
/// Send a request outside the frozen endpoint inventory.
pub async fn Client::raw(
  self : Self,
  http_method : @api.HttpMethod,
  path : String,
  query? : @api.Params = @api.Params::new(),
  body? : @api.RequestBody = @api.Empty,
) -> @api.Response[Json] raise @api.MegalodonError {
  let request = @api.build_request(
    self.base_url,
    path,
    http_method,
    query~,
    body~,
    access_token?=self.access_token,
    user_agent=self.user_agent,
    extra_headers=self.extra_headers,
  )
  let response = self.transport.send(request) catch {
    error => raise @api.to_megalodon_error(error)
  }
  @api.interpret(response)
}

///|
fn[T] decode_response(
  response : @api.Response[Json],
  decode : (Json) -> T raise @api.MegalodonError,
) -> @api.Response[T] raise @api.MegalodonError {
  {
    data: decode(response.data),
    status: response.status,
    headers: response.headers,
    pagination: response.pagination,
  }
}

///|
fn[T] decode_array(
  json : Json,
  name : String,
  decode : (Json) -> T raise @api.MegalodonError,
) -> Array[T] raise @api.MegalodonError {
  guard json is Array(items) else {
    raise @api.InvalidEntity(entity=name, detail="expected an array")
  }
  let result = []
  for item in items {
    result.push(decode(item))
  }
  result
}

///|
fn decode_object(
  json : Json,
  name : String,
) -> @entity.EntityObject raise @api.MegalodonError {
  @entity.EntityObject::from_json(json, name)
}

///|
fn object_response(
  response : @api.Response[Json],
  name : String,
) -> @api.Response[@entity.EntityObject] raise @api.MegalodonError {
  decode_response(response, json => decode_object(json, name))
}

///|
fn object_array_response(
  response : @api.Response[Json],
  name : String,
) -> @api.Response[Array[@entity.EntityObject]] raise @api.MegalodonError {
  decode_response(response, json => {
    decode_array(json, name, item => decode_object(item, name))
  })
}
