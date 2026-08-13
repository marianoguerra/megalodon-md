///|
test "account preserves unknown vendor fields" {
  let json : Json = {
    "id": "1",
    "username": "alice",
    "acct": "alice",
    "display_name": "Alice",
    "created_at": "2024-01-01T00:00:00Z",
    "note": "hi",
    "url": "https://example.social/@alice",
    "avatar": "https://example.social/a.png",
    "header": "https://example.social/h.png",
    "locked": false,
    "bot": false,
    "pleroma": { "is_admin": false },
  }
  let account = Account::from_json(json)
  assert_eq(account.id, "1")
  assert_eq(account.to_json(), json)
}

///|
fn test_account_json() -> Json {
  {
    "id": "1",
    "username": "alice",
    "acct": "alice@example.social",
    "display_name": "Alice",
    "created_at": "2019-03-26T21:30:32Z",
    "note": "engineer",
    "url": "https://example.social/@alice",
    "avatar": "",
    "header": "",
    "locked": false,
    "bot": false,
  }
}

///|
fn test_status_json(pleroma? : Json) -> Json {
  let fields : Map[String, Json] = {
    "id": "10",
    "uri": "https://example.social/notice/10",
    "url": "https://example.social/@alice/10",
    "account": test_account_json(),
    "content": "<p>hoge<br>fuga</p>",
    "created_at": "2019-03-26T21:40:32Z",
    "spoiler_text": "",
    "sensitive": false,
    "visibility": "public",
  }
  if pleroma is Some(value) {
    fields["pleroma"] = value
  }
  Json::object(fields)
}

///|
test "Mastodon and Pleroma notification names normalize symmetrically" {
  let cases : Array[(String, @entity.NotificationType, String)] = [
    ("follow", Follow, "follow"),
    ("favourite", Favourite, "favourite"),
    ("reblog", Reblog, "reblog"),
    ("mention", Mention, "mention"),
    ("poll", PollExpired, "poll_expired"),
    ("follow_request", FollowRequest, "follow_request"),
    ("status", Status, "status"),
    ("pleroma:emoji_reaction", Reaction, "reaction"),
    ("update", Update, "update"),
    ("move", Move, "move"),
  ]
  for item in cases {
    let (source, expected, encoded) = item
    assert_eq(@entity.NotificationType::parse(source), expected)
    assert_eq(expected.to_string(), encoded)
  }
  assert_eq(@entity.NotificationType::parse("future_event"), Unknown)
}

///|
test "Pleroma plain content is preserved without replacing HTML content" {
  let status = @entity.Status::from_json(
    test_status_json(pleroma={ "content": { "text/plain": "hoge\nfuga" } }),
  )
  assert_eq(status.content, "<p>hoge<br>fuga</p>")
  assert_eq(status.plain_content, Some("hoge\nfuga"))
  let mastodon = @entity.Status::from_json(test_status_json())
  assert_eq(mastodon.plain_content, None)
}

///|
test "preferences decode colon-delimited keys and round-trip losslessly" {
  let json : Json = {
    "posting:default:visibility": "public",
    "posting:default:sensitive": false,
    "posting:default:language": "Japanese",
    "reading:expand:media": "default",
    "reading:expand:spoilers": false,
  }
  let preferences = @entity.Preferences::from_json(json)
  assert_eq(preferences.posting_default_visibility, Public)
  assert_eq(preferences.posting_default_sensitive, false)
  assert_eq(preferences.posting_default_language, Some("Japanese"))
  assert_eq(preferences.reading_expand_media, Default)
  assert_eq(preferences.reading_expand_spoilers, false)
  assert_eq(preferences.to_json(), json)
}

///|
test "Pleroma marker metadata survives decoding and round-trip" {
  let json : Json = {
    "notifications": {
      "last_read_id": "1",
      "version": 2,
      "updated_at": "2020-01-02T03:04:05",
      "pleroma": { "unread_count": 3 },
    },
  }
  let marker = @entity.Marker::from_json(json)
  guard marker.notifications is Some(notifications) else {
    fail("expected notifications marker")
  }
  assert_eq(notifications.last_read_id, "1")
  assert_eq(notifications.version, 2L)
  assert_eq(notifications.updated_at, "2020-01-02T03:04:05")
  assert_eq(notifications.unread_count, Some(3L))
  assert_eq(marker.to_json(), json)
}
