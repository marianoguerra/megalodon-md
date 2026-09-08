///|
pub struct FakeTransport {
  responses : Array[@api.HttpResponse]
  sent : Array[@api.HttpRequest]
  mut index : Int
  description : String
}

///|
pub fn FakeTransport::new(
  responses : Array[@api.HttpResponse],
  description? : String = "fake transport",
) -> FakeTransport {
  { responses, sent: [], index: 0, description, }
}

///|
pub fn response(
  status : Int,
  body : String,
  headers? : Array[(String, String)] = [],
) -> @api.HttpResponse {
  let normalized : Map[String, String] = Map([])
  for entry in headers {
    let (name, value) = entry
    normalized[name.to_lower()] = value
  }
  { status, headers: normalized, body: @utf8.encode(body), }
}

///|
pub fn json_response(
  body : String,
  headers? : Array[(String, String)] = [],
) -> @api.HttpResponse {
  let all = headers.copy()
  all.push(("content-type", "application/json"))
  response(200, body, headers=all)
}

///|
pub fn FakeTransport::ok(bodies : Array[String]) -> FakeTransport {
  FakeTransport::new(bodies.map(body => json_response(body)))
}

///|
pub fn FakeTransport::sent_count(self : Self) -> Int {
  self.sent.length()
}

///|
pub fn FakeTransport::request(self : Self, index : Int) -> @api.HttpRequest {
  self.sent[index]
}

///|
pub fn FakeTransport::last_request(self : Self) -> @api.HttpRequest? {
  self.sent.last()
}

///|
pub impl @api.Transport for FakeTransport with fn send(self, request) {
  self.sent.push(request)
  if self.index >= self.responses.length() {
    abort("\{self.description}: no response scripted for \{request.url}")
  }
  let response = self.responses[self.index]
  self.index += 1
  response
}

///|
pub impl @api.Transport for FakeTransport with fn describe(self) {
  self.description
}
