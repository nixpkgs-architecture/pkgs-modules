Problems:
- In source code, feature flags and dependency arguments are mixed and hard to distinguish

Is this in scope?
- Applying modifications to "all packages" or subscopes happens using `setup-hooks` or modification of `stdenv` ( or some subscope equivalent, e.g. `pythonPackageWith` ). Can be messy, confusing, **not discoverable**.


Example of overlay order mattering:
```
lib.composeExtensions
  ( final: prev: { foo = ( prev.foo or [] ) ++ [1]; } )
  ( final: prev: { foo = [2]; } )
```

Related issues and pull requests
- https://github.com/NixOS/nixpkgs/issues/26561
- https://github.com/NixOS/nixpkgs/issues/44426


Some ideas:
- Subset of common `mkDerivation` fields can be typed for convenient merges:
  - Ex: `options.buildInputs = lib.mkOption { type = lib.types.listOf lib.types.package; default = []; };`
    Allows multiple "imported" `config` files to construct a single list.
- Use `lib.evalModules` in "Nixpkgs function" to apply/evaluate config for individual packages.
  - Scope of modules? Per package? Covering the whole package set?
- Treat packages as libraries
  - only import the package modules that are needed to create your custom package set.



## Drawbacks
- Evaluation time may increase
- Module system can be an additional level of complexity both in terms of evaluation time and maintainence.
   - or the legacy `mkDerivation + callPackage` packages will be a maintenance burden, depending on perspective and success

## Use cases to take into account
- Global overrides, aka changing something for all packages
  - Changing a dependency
  - Using a separate stdenv
  - Cross compilation
  - Use a different mkDerivation, e.g. for debug symbols
  - Package-level reusable logic that shouldn't be hardcoded into mkDerivation
    - `pkgConfigModules`: https://github.com/NixOS/nixpkgs/issues/215162
- Where does `python.withPackages` fit? Kind of creates a new package set
