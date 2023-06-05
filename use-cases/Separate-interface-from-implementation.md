# Separate interface from implementation

## General information

The interface and implementation of package definitions should be separated to ensure better maintainability, flexibility, and compatibility between different tools and approaches. A well-defined interface would allow package maintainers to focus on the implementation details while providing stability and consistency for end-users. It would also enable out-of-tree packaging libraries to interoperate with Nixpkgs more effectively, reducing the need for duplicated efforts and custom workarounds.

## Concrete examples

Scenario 1: Out of tree implementations (eg. lang2nix)
Alice maintains a packaging library that simplifies python packaging. Because nixpkgs offers a well defined packaging interface, she is able to design her library so that it provides good stability without suffering from sudden breakages introduced by implementation changes in nixpkgs.

Scenario 2: Change implementation details
Bob is a maintainer of the python framework in nixpkgs. He makes an improvement on the python packaging logic. He can be confident about not breaking downstream packages because he only changed the implementation, not the interface.

Scenario 3: Mixing different implementations
Carl wants to build a python project with dependencies. Some of the dependencies are defined by a lock file and are not available from nixpkgs. Carl would like to build some of the packages using poetry2nix while mixing in other existing package from nixpkgs seamlessly.

Scenario 4: Upgrading a package
Dave does some refactoring to the Emacs Nix expression in Nixpkgs, but it's reverted because it breaks things for some users who were doing some `.override*` on Emacs. Dave would like to know what parts of the Emacs Nix expression should be considered an "interface".
## Current problems

**Non-composable implementations**: Different implementations like the one from nixpkgs and out of tree packaging libraries (eg. lang2nix) are often incompatible. They often cannot be easily combined and there is a lock-in to a certain tool. For example, if poetry2nix is used for python, the user cannot simply inherit all the well-maintained build logic from nixpkgs. The logic from nixpkgs has to be duplicated manually, by individual users or the tools community.

**Mental overhead by too many interfaces**: Not having a standard interface results in many tools having different interfaces. That introduces mental overhead and steepens the learning curve of Nix more than it already is. It makes it hard to switch from one tool to another. Often complex ad-hoc hacks have to be used to circumvent the limitations of a single tool just because switching the implementation for a single package is not feasible.

**Fragile out-of-tree implementations**: Out-of-tree packaging implementations can be fragile if they try to re-use code from nixpkgs, as it is never clear what the actual API is and also the API can change at any time, resulting in breakages

**Complexity of out-of-tree implementations**: Out-of-tree packaging implementations often have to introduce extra complexity when they re-use code from other implementations. Due to the lack of an official API, they require workarounds to mitigate breakages or to establish compatibility with multiple versions of nixpkgs.

**Conflicts, collisions, infinite recursions**: When manipulating dependency trees of existing package sets, it's easy to run into conflicts, collisions, or hard-to-debug infinite recursions because there is no well-thought-out interface to manipulate dependency trees safely.

