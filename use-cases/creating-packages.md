# Creating new derivations

There is a constant need to create new derivations using Nix. Derivations can have various types of dependencies, build steps and configurations. Because of the build sandbox, derivations are restricted, which can be problematic for certain tooling, therefore requiring special care to get working. This can be especially tricky for inputs that need to be fetched from the internet. Derivations in Nixpkgs should also follow certain guidelines, such as complete `meta` fields, multiple output conventions and runtime purity.

## Concrete Example

Scenario 1: Packaging a third-party C program for Nixpkgs
Alice wants to use a program that is not yet packaged for Nix, so she wants to create a new declaration for it and upstream it to Nixpkgs. Looking at the source code on GitHub, she notices that the program is written in C, requires a number of dependencies and has a custom build script. All of this needs to be specified in a single Nix file. After an initial declaration, she tries to build it, but it fails with some error. After some iterations, she manages to finish the declaration. Testing the result reveals some problems, but after some adjustments it works. After a PR to Nixpkgs she receives some feedback from CI and reviewers, but it gets merged after that is addressed.

Scenario 2: Packaging your own library with C and Python bindings
Bob is the author of a useful library that he wants to write a Nix build for, for others to easily use it. He wants to create a Nix file in his repository that separately defines the C library and Python bindings from the same source build, so that users that don't need the Python bindings don't have to fetch them. He also wants to run the tests for both parts to ensure they work, which he wants to integrate into CI.

## Current Problems
1. **Poor builder documentation**: The available language builders, their arguments, semantics and results are often hard to discover and understand. There's barely any documentation for most builders, often requiring looking at the source to understand them.
2. **Inconsistencies**: Different language builders have inconsistencies among themselves, such as the requirement for `pname`/`version`/`name`, which phases are run, how to specify dependencies and how to run tests.
3. **Poor multi-language support**: There's barely any support for building packages using multiple languages in a single derivation.
4. **Poor errors**: When making a mistake during packaging, it's easy to get either no error message at all, or a very poor one. E.g. when a hash doesn't match, when a dependency is missing, when an argument was given the wrong type, when escaping of attributes is not right.
5. **NixOS inconsistencies**: Declaring NixOS systems is entirely different from declaring packages, therefore requiring users to learn both ways.
6. **Lack of compositionality**: Language builders are mostly implemented as functions that wrap `mkDerivation`, such as `buildPythonPackage` or `buildRustPackage`. This makes it impossible to combine such functions. By contrast, any number of setup hooks can be combined.
