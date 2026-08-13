///|
fn request_method_name(request_method : @http.RequestMethod) -> String {
  match request_method {
    Get => "GET"
    Post => "POST"
    Put => "PUT"
    Patch => "PATCH"
    Delete => "DELETE"
    _ => "OTHER"
  }
}

///|
fn make_request(
  origin : String,
  request_method : @api.HttpMethod,
  body : Bytes,
) -> @api.HttpRequest {
  {
    url: "\{origin}/reference?q=moon%20bit",
    http_method: request_method,
    headers: {
      "accept": "application/json",
      "content-type": "application/octet-stream",
      // The adapter must recompute this instead of trusting callers.
      "content-length": "9999",
    },
    body,
  }
}

///|
#skip("opt-in loopback socket test; run with --include-skipped")
async test "native transport sends every reference REST verb and preserves bytes" {
  let address = @socket.Addr::parse("127.0.0.1:0")
  let server = @http.Server(address)
  let origin = "http://\{server.addr}"
  let received : Array[(String, String, Bytes)] = []
  @async.with_task_group(group => {
    group.add_defer(() => server.close())
    group.spawn_bg(
      () => {
        server.run_forever(
          (request, body, connection) => {
            let payload = body.read_all().binary()
            received.push(
              (request_method_name(request.meth), request.path, payload),
            )
            connection.send_response(200, "OK", extra_headers={
              "Content-Type": "application/json",
              "X-Mixed-Case": "normalized",
            })
            connection.write(b"{\"ok\":true}")
            connection.end_response()
          },
          allow_failure=true,
        )
      },
      no_wait=true,
      allow_failure=true,
    )
    let adapter : &@api.Transport = @transport.HttpTransport::new(
      description="loopback reference test",
    )
    let cases : Array[(@api.HttpMethod, String, Bytes)] = [
      (Get, "GET", b""),
      (Post, "POST", b"post"),
      (Put, "PUT", b"put"),
      (Patch, "PATCH", b"\x00\xffpatch"),
      (Delete, "DELETE", b"delete"),
    ]
    for item in cases {
      let (request_method, expected_name, payload) = item
      let response = adapter.send(make_request(origin, request_method, payload))
      assert_eq(response.status, 200)
      assert_eq(response.header("x-mixed-case"), Some("normalized"))
      assert_eq(response.body_text(), "{\"ok\":true}")
      let index = received.length() - 1
      let (actual_name, path, actual_payload) = received[index]
      assert_eq(actual_name, expected_name)
      assert_eq(path, "/reference?q=moon%20bit")
      assert_eq(actual_payload, payload)
    }
    server.close()
  })
}
