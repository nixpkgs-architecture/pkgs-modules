# Customizing a package definition

## General information

A package definition is code that defines:

- how a package is built from source
- metadata for the package such as its name, license, or homepage
- dependencies of the package

Different users use packages differently. They might want to:

- turn optimizations on or off
- turn features on or of
- change versions of dependencies
- include patches
- add build steps
- add abstractions to the customization interface
- update metadata

## Concrete examples

Scenario 1: Adding a patch to a package
Alice wants to apply a patch to the examplePackage from Nixpkgs to fix a bug that affects her system. She needs a simple way to add the patch to the package definition without having to modify the entire package.

Scenario 2: Changing a build flag
Bob wants to build examplePackage with a specific feature flag enabled. He should be able to modify the package definition to enable the feature without affecting other users or requiring an entirely new package definition.

Scenario 3: Updating a package dependency
Carol wants to update a dependency of examplePackage to a newer version that is not yet available in Nixpkgs. She needs a way to specify the new dependency version in the package definition without having to rewrite the entire package.

## Current problems

1. **Lack of a unified API for customizing package definitions**: Users must rely on various ad-hoc mechanisms like overlays, `overrideAttrs`, or package-specific customization functions, making the process confusing and inconsistent.
2. **Discoverability of customization options**: The available options for customizing a package are often not documented or hard to find, making it difficult for users to know what changes they can make.
3. **Error-prone customizations**: There is no type safety or name checking for customizations, which can lead to errors that are difficult to debug. For example, if a user mistakenly writes `doUnpack = true;` instead of `dontUnpack = false;`, there is no error message to help them identify the issue.
4. **Manual merging of previous values**: When customizing a package, users must manually merge previous values, such as patches or dependencies. This can make customizations more verbose and repetitive than necessary.
5. **Order-dependent customizations**: Customizations are often order-dependent, meaning that changing the order of overlays or patches can result in unexpected behavior or errors.
6. **Performance impact**: Customizing packages can sometimes lead to a performance impact, as package sets and packages are evaluated for each subsequent overlay or customization.

