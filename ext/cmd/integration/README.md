# Live read-only integration

This executable is intentionally outside MoonBit test discovery and is not run
by CI. It performs unauthenticated, read-only requests against a real Mastodon
server. No access token is read and no mutating endpoint is called.

Run the default `mastodon.social` scenario explicitly:

```sh
moon -C ext run --target native cmd/integration
```

As of this writing, `mastodon.social` requires authentication for public
timeline reads. To include timeline, status, and account checks, provide a
read-only token explicitly:

```sh
MEGALODON_ACCESS_TOKEN=... moon -C ext run --target native cmd/integration
```

The token is read only by this opt-in process and is sent as an Authorization
header; it is never printed or written to disk.

Or supply another Mastodon-compatible origin:

```sh
moon -C ext run --target native cmd/integration -- https://example.social
```

Instance discovery is required. Public timeline, status lookup, account lookup,
and account statuses run when the server permits anonymous access or a token is
provided. Endpoints administrators commonly disable—local and tag
timelines, directory, trends, custom emoji, announcements, status context, and
legacy activity—are reported as `SKIP`. The peers list is also optional because
large instances can return several megabytes from that endpoint; it doubles as
a large-response stress probe for the selected transport.
