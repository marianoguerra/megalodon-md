default: check

check:
    moon -C megalodon check --target all
    moon -C http check --target native

test:
    moon -C megalodon test --target all
    moon -C http test --target native
    moon -C ext test --target native

fmt:
    moon fmt

ci: fmt check test

# Explicit network access; never part of `test` or `ci`.
integration:
    moon -C ext run --target native cmd/integration

# Explicit loopback socket access; skipped by the hermetic suite.
httpwire:
    moon -C ext test --target native --include-skipped test/httpwire
