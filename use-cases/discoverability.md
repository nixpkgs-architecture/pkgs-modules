# Discoverability of package customization options

## General information

It should be possible to customize packages without having to read the
source code of a package. That is, the user should be able to query
from the Nix CLI what the options of a package are. Ideally they
should also be able to set/override options from the CLI.

This requires some interface between Nix and Nixpkgs for
querying/setting options. See https://github.com/NixOS/nix/pull/6583
for a proof-of-concept implementation. It's not tied to any specific
option system implementation (like the NixOS module system), but just
requires customizable derivations to implement the interfaces required
by Nix.

## Concrete examples

(Taken from https://github.com/NixOS/nix/pull/6583.)

To show all the options of a packages:

```
# nix describe github:NixOS/nixpkgs#firefox
Option:      waylandSupport
Type:        bool
Value:       false
Description: Whether to enable support for the Wayland display server protocol.
Defined at:  <<pkgs/.../firefox.nix>>

Option:      src
Type:        derivation
Value:       <<derivation firefox-107.tar.gz>>
Description: The source code of this package.
Defined at:  <<pkgs/stdenv/.../unpack-source.nix>>

Option:      system
Type:        derivation
Value:       <<derivation firefox-107.tar.gz>>
Description: The type of the system on which to build this derivation.
Defined at:  <<pkgs/stdenv/.../derivation.nix>>

...
```

To build a package:

```
# nix build github:NixOS/nixpkgs#firefox
```

To override an option from the CLI:

```
# nix build github:NixOS/nixpkgs#firefox --pkg-option waylandSupport true
```

To override the source code from the command line:

```
# nix build github:NixOS/nixpkgs#firefox --pkg-option src ./my-firefox.tar.gz
```

## Current problems

1. No way to find out what options a package supports without looking at the Nix expression.
2. Package function arguments don't distinguish between options (`enableFoo ? true`) and dependencies (`libfoo`). Maybe it should be possible to enumerate/override the latter from the CLI but it's less important.
3. Option function arguments don't have types or documentation.
4. No easy way to override options from the CLI. You have to do something like `--expr 'firefox.override { enableFoo = true; }'`.
5. No easy way to get to the options of underlying functions like `mkDerivation` or `buildPythonPackage`.
