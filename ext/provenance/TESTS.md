# Reference test adoption

The reference test suites were reviewed at the revisions in `UPSTREAM.md`.
Tests are translated by behavior rather than copied line-for-line because the
MoonBit architecture has a runtime-independent transport boundary.

## Adopted

| Reference behavior | MoonBit coverage |
| --- | --- |
| Mastodon API client GET/POST/PUT/PATCH/DELETE | `ext/test/httpwire/httpwire_test.mbt` |
| Mastodon and Pleroma notification type conversion | `megalodon/entity/entity_test.mbt` |
| Unknown notification filtering | `ext/test/calls/calls_test.mbt` |
| Pleroma `text/plain` status content | `megalodon/entity/entity_test.mbt` |
| Preferences serialization/deserialization fixtures | `megalodon/entity/entity_test.mbt` |
| Pleroma marker fixture and unread count | `megalodon/entity/entity_test.mbt` |
| Detector cases for Mastodon, Pleroma, Akkoma, Friendica, Firefish, GoToSocial, Pixelfed and forks | `ext/test/calls/calls_test.mbt` |
| Unknown/malformed discovery failure | `ext/test/calls/calls_test.mbt` |
| Request cancellation/status/error behavior | portable error tests plus MoonBit structured cancellation; no Axios cancellation token exists in this API |
| Real read-only server smoke checks | `ext/cmd/integration`, opt-in and defaulting to `mastodon.social` |

The Rust tree repeats the same preferences tests in several server modules.
MoonBit has one normalized `Preferences` type, so the fixture is tested once
instead of duplicating an identical test per dialect.

## Intentionally not adopted

- WebSocket/parser tests: streaming is outside the REST release and requires a
  separate transport capability.
- Firefish reaction mapping and HTML conversion: this release detects Firefish
  but does not claim Misskey-style Firefish request/response translation.
- The TypeScript `expect(true).toBe(true)` placeholder.
- Live detector tests against a list of third-party instances: replaced with
  deterministic version/NodeInfo fixtures plus one explicit mastodon.social
  harness. This avoids flaky ordinary CI while retaining real compatibility
  coverage on demand.

## Running opt-in coverage

```sh
# Ephemeral loopback socket, all REST verbs
moon -C ext test --target native --include-skipped test/httpwire

# Real anonymous/read-only mastodon.social checks
moon -C ext run --target native cmd/integration

# Include auth-gated read operations using a read-only token
MEGALODON_ACCESS_TOKEN=... moon -C ext run --target native cmd/integration
```
