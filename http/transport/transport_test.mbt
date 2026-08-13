///|
test "absolute URLs are split into origin and request target" {
  let (origin, path) = split_url(
    "https://social.example/api/v1/accounts/1?limit=20",
  )
  assert_eq(origin, "https://social.example")
  assert_eq(path, "/api/v1/accounts/1?limit=20")
  let (local_origin, local_path) = split_url("http://localhost:3000")
  assert_eq(local_origin, "http://localhost:3000")
  assert_eq(local_path, "/")
}

///|
test "relative URLs are rejected" {
  try split_url("/api/v1/instance") catch {
    InvalidRequest(_) => ()
    _ => fail("expected InvalidRequest")
  } noraise {
    _ => fail("expected InvalidRequest")
  }
}

///|
test "non-HTTP URLs are rejected before opening a connection" {
  try split_url("ftp://social.example/api/v1/instance") catch {
    InvalidRequest(_) => ()
    _ => fail("expected InvalidRequest")
  } noraise {
    _ => fail("expected InvalidRequest")
  }
}
