# Be able to depend on features of other packages (feature resolution)


## General Information

Feature resolution is the process of determining which features of a package should be enabled or disabled based on the requirements of other packages that depend on it. In complex dependency chains, it is important to have a system that can automatically resolve and configure the features of a package to meet the needs of its dependents, avoiding potential conflicts or issues.


## Concrete Example

Scenario: A multimedia application (App A) requires a video processing library (Lib B) with a specific feature (Feature X) enabled. Another application (App C) also depends on the same video processing library (Lib B) but requires a different feature (Feature Y) to be enabled.

To successfully build both applications, the package manager must be able to resolve the features required by each application and configure the video processing library (Lib B) accordingly. This may involve building the library multiple times with different configurations or enabling both features simultaneously if they don't conflict.

## Current Problems

1. No automatic feature resolution: Since there is no automatic feature resolution in Nixpkgs, users have to manually manage feature dependencies, which can lead to conflicts and challenges in maintaining complex package ecosystems.
2. Closure Size: Having to manually override packages in order to enable features can lead to multiple variants of the same package ending up in the closure.
3. Lack of feature documentation: The available features of a package and their dependencies are often poorly documented, making it difficult for users to know which features they can enable or disable and how they might affect other packages.
4. Inconsistent feature handling: Different packages in Nixpkgs handle features differently, leading to confusion and inconsistencies when trying to enable or disable specific features.
5. Performance implications: ad-hoc feature tweaking may lead to a package being built multiple times with different configurations, which can have a negative impact on build times and resource usage.
6. Language Integrations: Many language specific package managers have a feature system, eg. `Cargo features` in rust, `Flags` in Haskell, or `Extras` in python. Not having an equivalent system for nix, makes it more difficult to import packages from foreign ecosystems to nix and requires ad-hoc solutions.
