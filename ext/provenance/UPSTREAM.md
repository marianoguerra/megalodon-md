# Upstream references

The MoonBit implementation was developed against these frozen revisions:

- `h3poteto/megalodon-rs` at `2c3f942185eb6b07e4e8ffacd6cfbc13ab913922`
- `h3poteto/megalodon` at `9550bad14193f15da3fffe2081d0b59fdd6582c9`

The Rust implementation is canonical. The TypeScript implementation is used
for cross-server compatibility behavior and additional fixtures. The reference
clones are deliberately not vendored; tests and behavior ported from them cite
the source path in comments.

## Surface accounting

Every Rust trait method through `get_emoji_reaction` has a named MoonBit client
method. The only names intentionally absent are the seven WebSocket streaming
methods and `streaming_url`. Rust's `upload_media_reader` overload is represented
by `upload_media(Bytes, ...)`, which stays portable and does not impose a
filesystem or runtime stream type on the core package.

The endpoint table follows the Mastodon-compatible REST dialect shared by
Mastodon, Pleroma/Akkoma, Friendica, GoToSocial, Pixelfed, and their common
forks. Firefish is recognized by detection, but its separate Misskey-style
request/response translation is not presented as Mastodon compatibility; raw
requests remain available for such server-native APIs.
