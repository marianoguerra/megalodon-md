# Native wire conformance

The test in this package opens an ephemeral loopback socket, so it is skipped by
ordinary `moon test` runs. Execute it explicitly with:

```sh
moon -C ext test --target native --include-skipped test/httpwire
```

It verifies GET, POST, PUT, PATCH, and DELETE on the wire, including query
targets, binary request bodies, response bodies, and case-normalized headers.
