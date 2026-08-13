///|
/// Detect server software through the Mastodon instance endpoint first and
/// NodeInfo second, matching the reference libraries' fallback order.
pub async fn detect(
  transport : &@api.Transport,
  base_url : String,
) -> @client.ServerSoftware raise @api.MegalodonError {
  for path in ["/api/v2/instance", "/api/v1/instance"] {
    let request = @api.build_request(base_url, path, @api.Get)
    let response = transport.send(request) catch { _ => continue }
    if response.status >= 200 && response.status < 300 {
      if parse_instance(response.body_text()) is Some(software) {
        return software
      }
    }
  }
  let discovery = @api.build_request(
    base_url,
    "/.well-known/nodeinfo",
    @api.Get,
  )
  let response = transport.send(discovery) catch {
    error => raise @api.NodeInfo(error.to_string())
  }
  guard response.status >= 200 && response.status < 300 else {
    raise @api.NodeInfo("discovery returned HTTP \{response.status}")
  }
  let document = @json.parse(response.body_text()) catch {
    error => raise @api.NodeInfo(error.to_string())
  }
  guard nodeinfo_href(document) is Some(href) else {
    raise @api.NodeInfo("discovery document has no schema 2.x link")
  }
  let nodeinfo_request = @api.build_request("", href, @api.Get)
  let nodeinfo_response = transport.send(nodeinfo_request) catch {
    error => raise @api.NodeInfo(error.to_string())
  }
  guard nodeinfo_response.status >= 200 && nodeinfo_response.status < 300 else {
    raise @api.NodeInfo("nodeinfo returned HTTP \{nodeinfo_response.status}")
  }
  let nodeinfo = @json.parse(nodeinfo_response.body_text()) catch {
    error => raise @api.NodeInfo(error.to_string())
  }
  guard nodeinfo is Object(root) else {
    raise @api.NodeInfo("nodeinfo is not an object")
  }
  guard root.get("software") is Some(Object(software)) else {
    raise @api.NodeInfo("nodeinfo has no software object")
  }
  guard software.get("name") is Some(String(name)) else {
    raise @api.NodeInfo("nodeinfo has no software.name")
  }
  @client.ServerSoftware::parse(name)
}

///|
fn parse_instance(body : String) -> @client.ServerSoftware? {
  let json = @json.parse(body) catch { _ => return None }
  guard json is Object(fields) else { return None }
  if fields.get("version") is Some(String(version)) {
    let lower = version.to_lower()
    for
      name in [
        "pleroma", "akkoma", "friendica", "firefish", "calckey", "gotosocial", "pixelfed",
        "hometown", "iceshrimp", "mastodon",
      ] {
      if lower.contains(name) {
        return Some(@client.ServerSoftware::parse(name))
      }
    }
    return Some(@client.Mastodon)
  }
  None
}

///|
fn nodeinfo_href(json : Json) -> String? {
  guard json is Object(fields) else { return None }
  guard fields.get("links") is Some(Array(links)) else { return None }
  for link in links {
    guard link is Object(item) else { continue }
    guard item.get("rel") is Some(String(rel)) else { continue }
    guard item.get("href") is Some(String(href)) else { continue }
    if rel.contains("nodeinfo/2.0") ||
      rel.contains("nodeinfo/2.1") ||
      rel.contains("/ns/schema/2.0") ||
      rel.contains("/ns/schema/2.1") {
      return Some(href)
    }
  }
  None
}
