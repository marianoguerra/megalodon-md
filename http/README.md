# megalodon-http

Native HTTP transport for
[`marianoguerra/megalodon`](https://mooncakes.io/docs/marianoguerra/megalodon/).
The core module is target-independent; this module contains the dependency on
`moonbitlang/async/http` and deliberately supports only the native target.

```sh
moon add marianoguerra/megalodon@0.1.0
moon add marianoguerra/megalodon-http@0.1.0
```

Add the packages to your `moon.pkg`:

```moonbit
import {
  "marianoguerra/megalodon/client",
  "marianoguerra/megalodon-http/transport",
}
```

```moonbit
async fn main {
  let transport = @transport.HttpTransport::new()
  let client = @client.Client::new(
    transport,
    @client.Mastodon,
    "https://mastodon.social",
    access_token="...",
  )
  let account = client.verify_account_credentials().data
  println(account.acct)
}
```
