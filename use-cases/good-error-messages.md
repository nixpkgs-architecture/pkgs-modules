# Good Error Messages

## General Information

Good error messages are crucial to the debugging process. They can provide the user with clear and concise information about what went wrong, why it went wrong, and possibly how to fix it. In the context of Nix packages, good error messages can be invaluable for both package developers and end users. They are especially important for beginners who may not yet be familiar with the intricacies of Nix packages and the Nix language.

The quality of error messages can significantly affect the user experience. For instance, if a package fails to build due to a missing dependency, the error message should clearly identify the missing dependency and where it's expected. When a package fails due to an incorrect configuration, the error message should indicate the problem with the configuration and ideally suggest a correct configuration.

## Concrete Example

Scenario: Typo in attribute name
Alice defines a new python package and accidentally defines dependencies via `PropagatedBuildInputs` instead of `propagatedBuildInputs`. An error is displayed indicating the that an unknown attribute was defined and provides a hint regarding the typo.

## Current Problems

1. Lack of type safety: Currently, users can provide incorrect types when defining attributes, causing confusion without any explicit error messages. For instance, a user might try to set `dontUnpack = "false"`, expecting it to behave the same as `dontUnpack = false`. However, due to the lack of type safety, the package still builds, albeit with unexpected behavior.
2. Absence of name checking: In the current ecosystem, if a user mistakenly types an incorrect attribute name, there is no mechanism to check and alert the user of this mistake. This can lead to situations where a misspelled attribute doesn't have the desired effect, and no errors are produced to guide the user. For instance, if a user types buildPhases instead of buildPhase, the intended build phases will not be executed, yet the system will not report an error, causing confusion and potential misbehavior in the package.
3. Unknown code origin: For build time errors it is often unclear where the code defining the failing logic is located. For example it is unclear if a failing command originates from the users overrides or from a setup hook that is included elsewhere.
