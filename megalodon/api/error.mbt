///|
pub(all) suberror MegalodonError {
  InvalidRequest(String)
  RequestFailed(String)
  HttpStatus(status~ : Int, body~ : String, headers~ : Map[String, String])
  PartialContent(headers~ : Map[String, String])
  InvalidJson(String)
  InvalidEntity(entity~ : String, detail~ : String)
  UnknownServer(String)
  NodeInfo(String)
} derive(Debug)

///|
pub fn MegalodonError::status(self : Self) -> Int? {
  match self {
    HttpStatus(status~, ..) => Some(status)
    PartialContent(..) => Some(206)
    _ => None
  }
}

///|
pub fn MegalodonError::describe_error(self : Self) -> String {
  match self {
    InvalidRequest(detail) => "invalid request: \{detail}"
    RequestFailed(detail) => "request failed: \{detail}"
    HttpStatus(status~, body~, ..) => "HTTP \{status}: \{body}"
    PartialContent(..) =>
      "HTTP 206: the requested resource is still being processed"
    InvalidJson(detail) => "invalid JSON response: \{detail}"
    InvalidEntity(entity~, detail~) => "invalid \{entity}: \{detail}"
    UnknownServer(name) => "unknown server software: \{name}"
    NodeInfo(detail) => "nodeinfo discovery failed: \{detail}"
  }
}

///|
pub impl Show for MegalodonError with fn output(self, logger) {
  logger.write_string(self.describe_error())
}

///|
pub fn to_megalodon_error(error : Error) -> MegalodonError {
  match error {
    InvalidRequest(_) as value => value
    RequestFailed(_) as value => value
    HttpStatus(..) as value => value
    PartialContent(..) as value => value
    InvalidJson(_) as value => value
    InvalidEntity(..) as value => value
    UnknownServer(_) as value => value
    NodeInfo(_) as value => value
    _ => RequestFailed(error.to_string())
  }
}
