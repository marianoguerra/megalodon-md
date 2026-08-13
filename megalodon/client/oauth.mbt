///|
pub fn authorization_url(
  base_url : String,
  client_id : String,
  redirect_uri? : String = "urn:ietf:wg:oauth:2.0:oob",
  scopes? : Array[String] = ["read", "write", "follow"],
) -> String {
  let params = @api.Params::new()
  params.put_string("client_id", Some(client_id))
  params.put_string("redirect_uri", Some(redirect_uri))
  params.put_string("response_type", Some("code"))
  params.put_string("scope", Some(scopes.join(" ")))
  let origin = if base_url.has_suffix("/") {
    base_url[:base_url.length() - 1].to_owned()
  } else {
    base_url
  }
  "\{origin}/oauth/authorize?\{params.encode()}"
}

///|
pub async fn Client::create_app(
  self : Self,
  client_name : String,
  redirect_uris? : String = "urn:ietf:wg:oauth:2.0:oob",
  scopes? : Array[String] = ["read", "write", "follow"],
  website? : String,
) -> @oauth.AppData raise @api.MegalodonError {
  let body : Map[String, Json] = {
    "client_name": client_name,
    "redirect_uris": redirect_uris,
    "scopes": scopes.join(" "),
  }
  if website is Some(value) {
    body["website"] = Json::string(value)
  }
  let response = self.call(CreateApp, body=@api.Json(Json::object(body)))
  @oauth.AppData::from_json(response.data)
}

///|
pub async fn Client::register_app(
  self : Self,
  client_name : String,
  redirect_uris? : String = "urn:ietf:wg:oauth:2.0:oob",
  scopes? : Array[String] = ["read", "write", "follow"],
  website? : String,
) -> @oauth.AppData raise @api.MegalodonError {
  let app = self.create_app(client_name, redirect_uris~, scopes~, website?)
  {
    id: app.id,
    name: app.name,
    website: app.website,
    redirect_uri: app.redirect_uri,
    client_id: app.client_id,
    client_secret: app.client_secret,
    url: Some(
      authorization_url(
        self.base_url,
        app.client_id,
        redirect_uri=redirect_uris,
        scopes~,
      ),
    ),
    session_token: app.session_token,
    raw: app.raw,
  }
}

///|
pub async fn Client::fetch_access_token(
  self : Self,
  client_id : String,
  client_secret : String,
  code : String,
  redirect_uri? : String = "urn:ietf:wg:oauth:2.0:oob",
) -> @oauth.TokenData raise @api.MegalodonError {
  let body : Json = {
    "client_id": client_id,
    "client_secret": client_secret,
    "code": code,
    "redirect_uri": redirect_uri,
    "grant_type": "authorization_code",
  }
  @oauth.TokenData::from_json(
    self.call(FetchAccessToken, body=@api.Json(body)).data,
  )
}

///|
pub async fn Client::refresh_access_token(
  self : Self,
  client_id : String,
  client_secret : String,
  refresh_token : String,
) -> @oauth.TokenData raise @api.MegalodonError {
  let body : Json = {
    "client_id": client_id,
    "client_secret": client_secret,
    "refresh_token": refresh_token,
    "grant_type": "refresh_token",
  }
  @oauth.TokenData::from_json(
    self.call(RefreshAccessToken, body=@api.Json(body)).data,
  )
}

///|
pub async fn Client::revoke_access_token(
  self : Self,
  client_id : String,
  client_secret : String,
  token : String,
) -> @api.Response[Json] raise @api.MegalodonError {
  self.call(
    RevokeAccessToken,
    body=@api.Json({
      "client_id": client_id,
      "client_secret": client_secret,
      "token": token,
    }),
  )
}
