# Incremental builds when only part of the derivation changes

In order to avoid unnecessary rebuilds and to increase cache efficency, we'd like to provide packagers with concepts and tools
to support incremental rebuilds of derivations.

We hope that our approach can greatly speed up the development cycle, especially for large projects with complex dependency and build graphs.

## Concrete Examples

TODO: maybe: zfs -> smb?

## Current problems

1. Input- vs Content-Adressed Paths: Nix standard model of input-addressed paths means that a changed input to a derivation changes it's output hash,
even if it the output itself hasn't changed at all. This in turn propagates upwards through the dependency tree, resulting in avoidable rebuilds.

2. Derivation granularity:
TODO: split up bigger derivations, learn about external build graphs from language specific tools and or bazel, et al?



## Related Work
* [[RFC 0062] Content Addressed Paths (https://github.com/tweag/rfcs/blob/cas-rfc/rfcs/0062-content-addressed-paths.md) helps with builds where
* [[RFC 0092] Computed derivations](https://github.com/NixOS/rfcs/blob/master/rfcs/0092-plan-dynamism.md) could help with splitting up larger builds into smaller derivations.

