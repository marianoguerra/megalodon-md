# megalodon-http

Native HTTP transport for [`marianoguerra/megalodon`](../megalodon/README.mbt.md).
The core package is target-independent; this package contains the only dependency
on `moonbitlang/async/http` and therefore deliberately supports the native target.

```moonbit
let transport = @transport.HttpTransport::new()
let client = @client.Client::new(
  transport,
  @client.Mastodon,
  "https://mastodon.social",
  access_token="...",
)
let account = client.verify_credentials()
```
