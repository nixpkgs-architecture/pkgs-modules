# Deeply Replacing Packages in Nixpkgs

## General Information

Replace all "instances" of a package across a dependency graph.
This may be replacing all usage in a package set, collection of package sets,
a collection of ad-hoc recipes, or a collection of flakes.

A possible motivation for _deep replacement_ may be to ensure that a security
fix provided by a new release of a piece of software is used "everywhere" in
the dependency graph.


## Concrete Examples

While the precise organization of packages will effect the complexity and
effort required to perform _deep replacement_, in general we say that this
is accomplished using helper functions such as `extend`, `overrideScope'`, and
`appendOverlays`, as well as the configuration field `overlays`.

### Simple Overlay

```nix
pkgs.extend ( final: prev: { foo = final.callPackage ./my-pkgs/foo {}; } )
```


<a name="Nested-Ex"></a>
### Nested Overlays

Nested overlays, "chained" vs. "composed" overlays, as and when to use `prev`
and `final` are common sources of confusion.
This can be particularly problematic when consuming overlays defined externally.

There is an extended example [here](../scratch/nested-extend.nix) that shows a
variety of common pitfalls, but the snippet below shows an abbreviated case.
Here the use of `nodejs` is contrived, what's important is that `nodejs` is
used to populate a nested scope `nodePackages`.
For the purposes of this example, we'll imagine the user is unaware of how
`nodePackages<VERSION>` attrsets should be used and naively use `nodePackages`
to add their own package definitions.
The core of this issue is that we attempt to merge an external overlay which
uses `nodejs@18` with an overlay using `nodejs@20`.
The user's goal here is really to use `nodejs@20` for the packages they define
and for their dependencies, but doing so inadvertently modifies executables
defined in our external overlay.

External Flake:
```nix
{
  outputs = { nixpkgs, ... }: let
    # We must split these into two overlays so `prev` holds the correct `nodejs`
    overlays.node18 = final: prev: { nodejs = prev.nodejs-18_x; };
    overlays.theirPkgs = final: prev: {
      nodePackages = prev.nodePackages.extend ( nfinal: nprev: {
        # Requires `nodejs@18' to avoid runtime errors.
        someExecutable = nfinal.callPackage ./. {};
      } );
    };
    overlays.default =
      nixpkgs.lib.composeExtensions overlays.node18 overlays.theirPkgs;
  in { inherit overlays; }
}
```

Our Flake:
```
{
  outputs = { nixpkgs, other, ... }: let
    overlays.deps   = other.overlays.default;
    overlays.node20 = final: prev: { nodejs = prev.nodejs-20_x; };
    overlays.myPkgs = final: prev: {
      nodePackages = prev.nodePackages.extend ( nfinal: nprev: {
        # Doesn't use any node modules from previous overlay, but requires
        # `nodejs@20' to avoid runtime errors.
        myModule = nfinal.callPackage ./module {};
      } );
      # Uses `someExecutable' from previous overlay.
      someTool = final.callPackage ./tool {};
    };
    overlays.default = nixpkgs.lib.composeManyExtensions [
      overlays.deps overlays.node20 overlays.myPkgs
    ];
  in {
    inherit overlays;
    packages.x86_64-linux = let
      pkgsFor = nixpkgs.legacyPackages.x86_64-linux.extend overlays.default;
    in { inherit (pkgsFor) nodePackages someTool; }
    # packages.<SYSTEM> = ...;
  }
}
```

In this example the user will encounter runtime crashes in `myTool` caused by
accidentally overriding `nodejs = nodejs-20_x;`
in `nodePackages.someExecutable` defined externally.
While we certainly have ways to avoid this category of issue, the process seen
above is already a challenge to understand - ideally a more intuitive pattern
could be offered to users.


## Current Problems

With this approach we have three main sources of complexity, none of which
truly prevent a user from accomplishing their goal, but we might suffice to
say that it may be worthwhile to provide a more straightforward mechanism
for handling this use case.

1. [github:NixOS/nixpkgs://lib/customisation.nix](https://github.com/NixOS/nixpkgs/blob/master/lib/customisation.nix)
routines aren't intuitively understood by many users.
   - `self`/`super` and `final`/`prev` are difficult for new users to understand.
   - Easy to accidentally trigger infinite recursion.
   - Some packages are not _truly_ overridable, which advanced users will only
     discover after a lengthy debugging session.

2. Nested scopes are difficult to locate, and the relationship between
   parent scopes and child scopes is opaque to users.
   - See [Nested Overlays](#Nested-Ex) example.

3. With ad-hoc recipes and flakes there isn't standardized usage of
   `overlays` that allow deep overriding of packages transitively.
   - Improved guidance on the use of `overlays` and `follows` in `flakes`
     could help a bit here.

