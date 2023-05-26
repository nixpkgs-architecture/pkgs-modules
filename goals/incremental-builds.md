# Incremental builds when only part of the derivation changes

In order to avoid unnecessary rebuilds and to increase cache efficency, we'd like to provide packagers with concepts and tools to support incremental rebuilds of derivations.

We hope that our approach can greatly speed up the development cycle, especially for large projects with complex dependency and build graphs.

## Related Projects

* [cargo2nix](https://github.com/cargo2nix/cargo2nix) supports [building crates isolated from each other](https://github.com/cargo2nix/cargo2nix#building-crates-isolated-from-each-other)

* [Floco](https://github.com/aakropotkin/floco/https://github.com/aakropotkin/floco/) splits a given nodejs package to at least 3 derivations or targets: "prepared" for use by
other nix builds, "global" for the package in it's installed form and "dist" containing a tarball of the package. (see phase granularity below)

* [nix-bazel](https://nix-bazel.build/)lets nix just manage inputs and uses bazel for incremental builds 


## Current problems

1. Input- vs Content-Adressed Paths: Nix standard model of input-addressed paths means that a changed input to a derivation changes it's output hash,
even if it the output itself hasn't changed at all. This in turn propagates upwards through the dependency tree, produces avoidable rebuilds and
tends to get worse as one uses more and smaller derivations.


2. Derivation Granularity / lack of information about the build graph: When derivations in nixpkgs shell out to external build tools, nix doesn't know anything 
about their compilation units. While various lang2nix tools exist to acquire the build graph from language-specific tools, they often need to rely on IFD
or recursive nix features. The existance of multiple popular lang2nix tools with widely different implementations might suggest that there's little consensus
about how to handle trade-offs of each approach in the community.


3. Derivation & Phase granularity: `stdenv`s phases aren't easily split into seperate derivations, which can be especially useful for larger derivations that
might fail in later stages. If `installPhase` fails, one need's to run `unpackPhase` and `buildPhase` again-



## Related Work & Discussions
* [[RFC 0062] Content Addressed Paths](https://github.com/NixOS/rfcs/blob/master/rfcs/0062-content-addressed-paths.md) helps with builds where
* [[RFC 0092] Computed derivations](https://github.com/NixOS/rfcs/blob/master/rfcs/0092-plan-dynamism.md) could help with splitting up larger builds into smaller derivations. 
* [2020 NixOS-Discourse-Thread on incremental builds](https://discourse.nixos.org/t/incremental-builds/9988)

