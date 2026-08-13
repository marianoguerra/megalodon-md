///|
let account_json : String =
  #|{"id":"42","username":"alice","acct":"alice","display_name":"Alice","created_at":"2024-01-01T00:00:00.000Z","note":"hello","url":"https://social.example/@alice","avatar":"https://social.example/avatar.png","header":"https://social.example/header.png","locked":false,"bot":false,"vendor_field":"kept"}

///|
let status_json : String =
  #|{"id":"99","uri":"https://social.example/users/alice/statuses/99","url":"https://social.example/@alice/99","account":{"id":"42","username":"alice","acct":"alice","display_name":"Alice","created_at":"2024-01-01T00:00:00.000Z","note":"hello","url":"https://social.example/@alice","avatar":"https://social.example/avatar.png","header":"https://social.example/header.png","locked":false,"bot":false},"content":"<p>Hello</p>","created_at":"2024-01-02T00:00:00.000Z","spoiler_text":"","sensitive":false,"visibility":"public"}

///|
fn new_client(fake : @testing.FakeTransport) -> @client.Client {
  @client.Client::new(
    fake,
    @client.Mastodon,
    "https://social.example",
    access_token="secret",
  )
}

///|
fn field(value : Json, name : String) -> Json? {
  match value {
    Object(fields) => fields.get(name)
    _ => None
  }
}

///|
async test "typed account calls preserve authentication, pagination and vendor data" {
  let fake = @testing.FakeTransport::new([
    @testing.json_response(account_json, headers=[
      (
        "Link", "<https://social.example/api/v1/accounts/42/followers?max_id=8>; rel=\"next\"",
      ),
    ]),
  ])
  let response = new_client(fake).verify_account_credentials()
  assert_eq(response.data.id, "42")
  assert_eq(field(response.data.raw, "vendor_field"), Some("kept".to_json()))
  assert_eq(
    response.pagination.next,
    Some("https://social.example/api/v1/accounts/42/followers?max_id=8"),
  )
  let request = fake.request(0)
  assert_eq(
    request.url,
    "https://social.example/api/v1/accounts/verify_credentials",
  )
  assert_eq(request.http_method, @api.Get)
  assert_eq(request.headers.get("authorization"), Some("Bearer secret"))
}

///|
async test "status creation encodes a JSON body through the portable client" {
  let fake = @testing.FakeTransport::ok([status_json])
  let response = new_client(fake).post_status(
    "Hello, Fediverse!",
    media_ids=["11", "12"],
    visibility=@entity.Public,
    language="en",
  )
  assert_eq(response.status, 200)
  let request = fake.request(0)
  assert_eq(request.url, "https://social.example/api/v1/statuses")
  assert_eq(request.http_method, @api.Post)
  assert_eq(request.headers.get("content-type"), Some("application/json"))
  let body = @json.parse(request.body_text())
  assert_eq(field(body, "status"), Some("Hello, Fediverse!".to_json()))
  assert_eq(field(body, "visibility"), Some("public".to_json()))
}

///|
async test "OAuth token exchange uses the standard endpoint and decodes refresh data" {
  let fake = @testing.FakeTransport::ok([
    "{\"access_token\":\"access\",\"token_type\":\"Bearer\",\"scope\":\"read write\",\"expires_in\":3600,\"refresh_token\":\"refresh\"}",
  ])
  let token = new_client(fake).fetch_access_token("id", "client-secret", "code")
  assert_eq(token.access_token, "access")
  assert_eq(token.refresh_token, Some("refresh"))
  assert_eq(fake.request(0).url, "https://social.example/oauth/token")
  assert_eq(fake.request(0).http_method, @api.Post)
}

///|
async test "server detection recognizes a Mastodon-compatible fork" {
  let fake = @testing.FakeTransport::ok([
    "{\"version\":\"3.5.0 (compatible; Akkoma 3.13.2)\"}",
  ])
  assert_eq(@detector.detect(fake, "https://social.example"), @client.Akkoma)
  assert_eq(fake.request(0).url, "https://social.example/api/v2/instance")
}

///|
async test "server detection falls back through NodeInfo" {
  let fake = @testing.FakeTransport::new([
    @testing.response(404, "missing"),
    @testing.response(404, "missing"),
    @testing.json_response(
      "{\"links\":[{\"rel\":\"http://nodeinfo.diaspora.software/ns/schema/2.0\",\"href\":\"https://social.example/nodeinfo/2.0\"}]}",
    ),
    @testing.json_response("{\"software\":{\"name\":\"gotosocial\"}}"),
  ])
  assert_eq(
    @detector.detect(fake, "https://social.example"),
    @client.GoToSocial,
  )
  assert_eq(fake.sent_count(), 4)
  assert_eq(fake.request(3).url, "https://social.example/nodeinfo/2.0")
}

///|
async test "malformed NodeInfo discovery fails with the library error" {
  let fake = @testing.FakeTransport::new([
    @testing.response(404, "missing"),
    @testing.response(404, "missing"),
    @testing.json_response("{\"links\":[]}"),
  ])
  try @detector.detect(fake, "https://unknown.example") catch {
    @api.NodeInfo(detail) => assert_true(detail.contains("no schema 2.x link"))
    _ => fail("expected NodeInfo")
  } noraise {
    _ => fail("expected detector failure")
  }
}

///|
async test "detector classifies the supported Mastodon-family version strings" {
  let cases : Array[(String, @client.ServerSoftware)] = [
    ("4.4.0", Mastodon),
    ("2.7.2 (compatible; Pleroma 2.7.2)", Pleroma),
    ("2.7.2 (compatible; Akkoma 3.13.2)", Akkoma),
    ("2024.12 Friendica", Friendica),
    ("gotosocial-0.19.1", GoToSocial),
    ("3.5.3 (compatible; Pixelfed 0.12.4)", Pixelfed),
    ("4.0.0+hometown-1.1.0", Hometown),
    ("2024.5.0-iceshrimp", Iceshrimp),
    ("firefish/20240206", Firefish),
  ]
  for item in cases {
    let (version, expected) = item
    let fake = @testing.FakeTransport::ok(["{\"version\":\"\{version}\"}"])
    assert_eq(@detector.detect(fake, "https://social.example"), expected)
  }
}

///|
async test "unknown notification events are ignored after known events decode" {
  let known = "{\"id\":\"1\",\"type\":\"follow\",\"created_at\":\"2021-01-31T23:33:26Z\",\"account\":\{account_json}}"
  let unknown = "{\"id\":\"2\",\"type\":\"future_event\",\"created_at\":\"2021-01-31T23:33:26Z\",\"account\":\{account_json}}"
  let fake = @testing.FakeTransport::ok(["[\{known},\{unknown}]"])
  let response = new_client(fake).get_notifications()
  assert_eq(response.data.length(), 1)
  assert_eq(response.data[0].notification_type, @entity.Follow)
}

///|
test "the native adapter satisfies the portable transport trait" {
  let http : &@api.Transport = @transport.HttpTransport::new(
    description="social.example",
  )
  assert_eq(http.describe(), "social.example")
}
