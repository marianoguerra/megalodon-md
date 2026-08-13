# megalodon

A portable Mastodon-compatible Fediverse client for MoonBit. The core module
has no external dependencies and supports wasm, wasm-gc, JavaScript, and native.
Network access is supplied through `@api.Transport`; native applications can
install `marianoguerra/megalodon-http`.

```mbt nocheck
let transport = @transport.HttpTransport::new()
let client = @client.Client::new(
  transport,
  @client.Mastodon,
  "https://mastodon.social",
  access_token="...",
)
let account = client.verify_account_credentials().data
println(account.acct)
```

The generic `Client::call` accepts every non-streaming REST/OAuth operation in
the frozen reference interface, and the same operations have named client
methods. `Client::raw` is available for server extensions that postdate this
release.

The core intentionally does not import an async runtime. An `async` trait
method is part of MoonBit's language-level API; the executor belongs to the
application or concrete transport.
