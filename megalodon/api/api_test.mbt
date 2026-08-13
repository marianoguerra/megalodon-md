///|
test "query encoding uses UTF-8 and repeated keys" {
  let params = Params::new()
  params.put_string("q", Some("café"))
  params.put_strings("id[]", Some(["1", "2"]))
  assert_eq(params.encode(), "q=caf%C3%A9&id%5B%5D=1&id%5B%5D=2")
}

///|
test "request construction is byte accurate" {
  let request = build_request(
    "https://example.social/",
    "/api/v1/statuses",
    Post,
    body=Json({ "status": "héllo" }),
    access_token="secret",
  )
  assert_eq(request.url, "https://example.social/api/v1/statuses")
  assert_eq(request.headers["authorization"], "Bearer secret")
  assert_eq(request.content_length(), request.body.length())
}

///|
test "link headers expose pagination URLs" {
  let headers = {
    "link": "<https://x/api?max_id=2>; rel=\"next\", <https://x/api?min_id=9>; rel=\"prev\"",
  }
  let page = pagination_from_headers(headers)
  assert_eq(page.next, Some("https://x/api?max_id=2"))
  assert_eq(page.prev, Some("https://x/api?min_id=9"))
}

///|
test "HTTP failures retain status, body and response headers" {
  let headers = { "retry-after": "30" }
  let response : HttpResponse = {
    status: 429,
    headers,
    body: @utf8.encode("slow down"),
  }
  try interpret(response) |> ignore catch {
    HttpStatus(status~, body~, headers~) => {
      assert_eq(status, 429)
      assert_eq(body, "slow down")
      assert_eq(headers.get("retry-after"), Some("30"))
    }
    _ => fail("expected HttpStatus")
  } noraise {
    _ => fail("expected HttpStatus")
  }
}

///|
test "invalid success bodies are classified as JSON errors" {
  let response : HttpResponse = {
    status: 200,
    headers: Map([]),
    body: @utf8.encode("not json"),
  }
  try interpret(response) |> ignore catch {
    InvalidJson(_) => ()
    _ => fail("expected InvalidJson")
  } noraise {
    _ => fail("expected InvalidJson")
  }
}

///|
test "multipart construction preserves arbitrary file bytes" {
  let file = b"\x00\xffMoonBit"
  let encoded = multipart_file(
    "boundary",
    "file",
    "avatar.bin",
    "application/octet-stream",
    file,
    fields=[("description", "avatar")],
  )
  assert_eq(encoded.content_type, "multipart/form-data; boundary=boundary")
  assert_true(encoded.body.length() > file.length())
  assert_true(@utf8.decode_lossy(encoded.body[:]).contains("description"))
}
