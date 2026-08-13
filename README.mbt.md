# megalodon for MoonBit

A MoonBit client for Mastodon-compatible Fediverse REST APIs, ported from
[`h3poteto/megalodon-rs`](https://github.com/h3poteto/megalodon-rs) with the
TypeScript [`h3poteto/megalodon`](https://github.com/h3poteto/megalodon) used as
a compatibility reference.

The repository is a workspace with a deliberate transport boundary:

- `marianoguerra/megalodon` is the portable core. It builds for native,
  JavaScript, WebAssembly, and WebAssembly-GC and has no async/runtime or HTTP
  dependency.
- `marianoguerra/megalodon-http` is the native adapter based on
  `moonbitlang/async/http`.
- `marianoguerra/megalodon-ext` is unpublished conformance and integration
  testing support.

## Usage

```moonbit
let transport = @transport.HttpTransport::new(
  description="mastodon.social",
)
let client = @client.Client::new(
  transport,
  @client.Mastodon,
  "https://mastodon.social",
  access_token="...",
)
let account = client.verify_account_credentials().data
println(account.acct)
```

For a browser, worker, embedded host, or test, implement the two-method
`@api.Transport` trait and reuse the same client and entity packages. The
portable `@testing.FakeTransport` is included for deterministic tests.

## API scope

The frozen non-streaming, non-admin Rust trait is represented by `Endpoint`,
including OAuth, accounts, relationships, statuses, timelines, media,
notifications, lists, filters, polls, search, instance metadata,
announcements, and Pleroma emoji reactions. Named `Client` methods cover that
inventory; `Client::call` and `Client::raw` remain available for less common or
new server extensions.

The named routing table targets the Mastodon-compatible REST dialect used by
Mastodon and compatible Pleroma/Akkoma, Friendica, GoToSocial, Pixelfed, and
related servers. Detection can identify Firefish, but Firefish's separate
Misskey-style API is accessed with `Client::raw` rather than silently rewriting
Mastodon requests.

Core account, status, media, OAuth, pagination, and error values are normalized
types. Less stable entities use `EntityObject`, which checks that the response
has the expected object shape and preserves its complete JSON without losing
vendor fields.

WebSocket streaming and administrative APIs are intentionally outside this
release. They require a second capability boundary and should not make the REST
core target-specific.

## Package layout

The implementation does not split ActivityPub vocabulary into a separate
package. The upstream public API is an HTTP client for Mastodon-family REST
representations rather than an ActivityPub object model, and those response
types cross-reference one another heavily. Splitting them would add dependency
cycles and conversion layers without producing an independently useful
ActivityPub library. Transport, client, OAuth, detector, entities, and testing
are separate packages instead.

## Development

```sh
moon -C megalodon check --target all
moon -C megalodon test --target all
moon -C http test --target native
moon -C ext test --target native
```

Socket and internet integration checks are opt-in:

```sh
moon -C ext test --target native --include-skipped test/httpwire
moon -C ext run --target native cmd/integration
```

`mastodon.social` currently requires authentication for timeline reads. Set
`MEGALODON_ACCESS_TOKEN` to a read-only token to include those operations. The
reference-test adoption matrix is recorded in
[`ext/provenance/TESTS.md`](ext/provenance/TESTS.md).

The exact upstream revisions used for the port are recorded in
[`ext/provenance/UPSTREAM.md`](ext/provenance/UPSTREAM.md).

## Publishing

The two public modules are released separately and must be published in
dependency order: first `marianoguerra/megalodon`, then
`marianoguerra/megalodon-http`. See [`PUBLISHING.md`](PUBLISHING.md) for the
first-release checklist.
