///|
/// Pagination accepted by most collection endpoints.
pub fn page_params(
  limit? : Int,
  max_id? : String,
  since_id? : String,
  min_id? : String,
) -> @api.Params {
  let params = @api.Params::new()
  params.put_int("limit", limit.map(value => value.to_int64()))
  params.put_string("max_id", max_id)
  params.put_string("since_id", since_id)
  params.put_string("min_id", min_id)
  params
}

///|
pub(all) struct PollOptions {
  options : Array[String]
  expires_in : Int64?
  multiple : Bool?
  hide_totals : Bool?
} derive(Eq, Debug)

///|
pub(all) enum SearchType {
  Accounts
  Hashtags
  Statuses
} derive(Eq, Debug)

///|
pub fn SearchType::to_string(self : Self) -> String {
  match self {
    Accounts => "accounts"
    Hashtags => "hashtags"
    Statuses => "statuses"
  }
}

///|
pub(all) enum DirectoryOrder {
  Active
  New
} derive(Eq, Debug)

///|
pub fn DirectoryOrder::to_string(self : Self) -> String {
  match self {
    Active => "active"
    New => "new"
  }
}
