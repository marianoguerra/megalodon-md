# Publishing to Mooncakes

This repository publishes two modules at the same version:

- `marianoguerra/megalodon`: portable core and transport trait.
- `marianoguerra/megalodon-http`: native HTTP transport.

`marianoguerra/megalodon-ext` contains development and integration tooling and
is not published.

## Release checklist

1. From the repository root, run the hermetic release checks:

   ```sh
   just release-check
   git diff --check
   git status --short
   ```

2. Log into Mooncakes if needed:

   ```sh
   moon login
   ```

3. Publish the portable core first:

   ```sh
   moon -C megalodon publish --dry-run --frozen
   moon -C megalodon publish --frozen
   ```

4. Once `marianoguerra/megalodon@0.1.1` is available from the registry,
   publish the native transport:

   ```sh
   moon update
   moon -C http publish --dry-run
   moon -C http publish
   ```

   These two run without `--frozen`: the isolated validation must download the
   freshly published `marianoguerra/megalodon` into its own scratch module
   directory, which `--frozen` forbids.

5. Confirm both registry pages, then tag the exact release commit as `v0.1.1`.

The dependency order matters because the isolated validation of
`megalodon-http` resolves `marianoguerra/megalodon@0.1.1` from Mooncakes rather
than from this workspace.
