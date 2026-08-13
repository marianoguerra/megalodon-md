///|
pub(all) struct Pagination {
  next : String?
  prev : String?
} derive(Eq, Debug)

///|
pub(all) struct Response[T] {
  data : T
  status : Int
  headers : Map[String, String]
  pagination : Pagination
} derive(Eq, Debug)

///|
pub fn[A, B] Response::map(self : Response[A], f : (A) -> B) -> Response[B] {
  {
    data: f(self.data),
    status: self.status,
    headers: self.headers,
    pagination: self.pagination,
  }
}

///|
pub fn pagination_from_headers(headers : Map[String, String]) -> Pagination {
  guard headers.get("link") is Some(value) else {
    return { next: None, prev: None }
  }
  let mut next : String? = None
  let mut prev : String? = None
  for part in value.split(",") {
    let item = part.trim()
    guard item.split_once(";") is Some((url_part, rel_part)) else { continue }
    guard url_part.trim() is ['<', .. middle, '>'] else { continue }
    let url = middle.to_owned()
    let rel = rel_part.trim().to_owned()
    if rel.contains("rel=\"next\"") {
      next = Some(url)
    } else if rel.contains("rel=\"prev\"") {
      prev = Some(url)
    }
  }
  { next, prev }
}
