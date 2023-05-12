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


### Nested Overlay

This fails to use Node.js v14 in `nodePackages`, which is unexpected to
most users.
```nix
# XXX: Incorrect usage
pkgs.extend ( final: prev: {
  nodejs       = prev.nodejs-14_x;
  nodePackages = prev.nodePackages.extend ( nfinal: nprev: {
    bar = nfinal.callPackage ./my-pkgs/bar {};
  } );
} )
```

To accomplish use Node.js v14 here the user would need two overlays.
```nix
let
  pkgsN14 = pkgs.extend ( final: prev: { nodejs = prev.nodejs-14_x; } );
in pkgsN14.extend ( final: prev: {
  nodePackages = prev.nodePackages.extend ( nfinal: nprev: {
    bar = nfinal.callPackage ./my-pkgs/bar {};
  } );
} )
```



## Current Problems

With this approach we have three main sources of complexity, none of which
truly prevent a user from accomplishing their goal; but we might suffice to
say that it may be worthwhile to provide a more straightforward mechanism
for handling this use case.

1. [github:NixOS/nixpkgs://lib/customisation.nix](https://github.com/NixOS/nixpkgs/blob/master/lib/customisation.nix)
routines aren't intuitively understood by many users.
   - `self`/`super` and `final`/`prev` are difficult for new users to understand.
   - Easy to accidentally trigger infinite recursion.
   - Some packages are not _truly_ overridable, which advanced users will only
     discover after a lengthy debugging session.

2. Nested scopes are difficult to locate, and the relationship between
   parent scopes and child scopes is not opaque to users.
   - See [[Nested Overlays]] example.

3. With ad-hoc recipes and flakes there isn't standardized usage of
   `overlays` that allow deep overriding of packages transitively.
   - Improved guidance on the use of `overlays` and `follows` in `flakes`
     could help a bit here.

