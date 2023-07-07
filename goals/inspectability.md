# Inspectability

To help with debugging, it should be possible to inspect what's going on under the hood to a certain extent.

There's two separate ways to have inspectability:
- Interactive inspectability: Being able to select the exact internal value you'd like to see the value of
- Tracing inspectability: Being able to enable logging and getting enough information that way to figure out the values you'd like to see the value of

## Interactive inspectability example: NixOS options

The `services.openssh.enable` NixOS option causes a variety of other options to be defined underneath.

With the module system it's currently not possible to easily know which other options get affected.
One has to look at the implementation of the modules to figure that out, such as the [`the module where the option is defined`](https://github.com/NixOS/nixpkgs/blob/ccde02dcbc29eab5fe745c5f4c08c905584627bc/nixos/modules/services/networking/ssh/sshd.nix#L435).
Unfortunately [_any_ module can read this option](https://github.com/NixOS/nixpkgs/blob/ccde02dcbc29eab5fe745c5f4c08c905584627bc/nixos/modules/virtualisation/digital-ocean-config.nix#L111) and influence other options based on it.
While it's [possible to know where the option was declared and defined](https://github.com/NixOS/nixpkgs/blob/ccde02dcbc29eab5fe745c5f4c08c905584627bc/lib/modules.nix#L728-L767), it's not possible to know from where the option is read.

However once you do know which options get affected (or if you just [automate looking at all options](https://github.com/NixOS/nixpkgs/issues/190033)), you can just print the values of those in a `nix repl`, even if those options aren't meant to be part of the API.

## Interactive inspectability example: Nix debugger

Another form of inspectability is using a debugger, which Nix evaluation [somewhat recently](https://github.com/NixOS/nix/pull/5416) gained support for:

```
$ nix repl -f '<nixpkgs>' --debugger --ignore-try
Welcome to Nix 2.15.1. Type :? for help.

Loading installable ''...
Added 19234 variables.
nix-repl> pkgs.hello.overrideAttrs { x = 10; }
error: attempt to call something which is not a function but a set

       at /nix/store/kay5b9yff5f07wnkgwziqz0k77qhqrj6-nixpkgs-patched-source/pkgs/stdenv/generic/make-derivation.nix:34:21:

           33|             # arise from flipping an overlay's parameters in some cases.
           34|             let x = f0 super;
             |                     ^
           35|             in


Starting REPL to allow you to inspect the current state of the evaluator.

Welcome to Nix 2.15.1. Type :? for help.

nix-repl> f0
{ x = 10; }
```

## Tracing inspectability example: Nix verbosity

With Nix it's possible to increase the verbosity by passing additional `-v`'s.
This allows some inspectability into what's going on during Nix commands, e.g. we can see which files are evaluated, example:

```
$ nix-build '<nixpkgs>' -A hello -v
evaluating file '/nix/store/kay5b9yff5f07wnkgwziqz0k77qhqrj6-nixpkgs-patched-source/lib/minver.nix'
evaluating file '/nix/store/kay5b9yff5f07wnkgwziqz0k77qhqrj6-nixpkgs-patched-source/pkgs/top-level/impure.nix'
evaluating file '/nix/store/kay5b9yff5f07wnkgwziqz0k77qhqrj6-nixpkgs-patched-source/pkgs/top-level/default.nix'
evaluating file '/nix/store/kay5b9yff5f07wnkgwziqz0k77qhqrj6-nixpkgs-patched-source/lib/default.nix'
[...]
evaluating file '/nix/store/kay5b9yff5f07wnkgwziqz0k77qhqrj6-nixpkgs-patched-source/pkgs/development/libraries/nghttp2/default.nix'
/nix/store/9dpz09dzkx578v8q0rk1qpklmxkv2qys-hello-2.12.1
```


## Tracing inspectability example: mkDerivation build tracing

By default at least, derivations defined with `mkDerivation` are built using bash, whose evaluation can be fully traced by prepending `set -x`, enabling bash tracing:

```
$ nix-build -E 'with import <nixpkgs> {}; hello.overrideAttrs (old: { preUnpack = "set -x" + old.preUnpack or ""; })'
this derivation will be built:
  /nix/store/ncymnxknkd1azkjh3wpams691cbzlj0i-hello-2.12.1.drv
building '/nix/store/ncymnxknkd1azkjh3wpams691cbzlj0i-hello-2.12.1.drv'...
unpacking sources
++ return 0
++ '[' -z '' ']'
++ '[' -z /nix/store/pa10z4ngm0g83kx9mssrqzz30s84vq7k-hello-2.12.1.tar.gz ']'
++ srcs=/nix/store/pa10z4ngm0g83kx9mssrqzz30s84vq7k-hello-2.12.1.tar.gz
++ local -a srcsArray
++ '[' -n '' ']'
++ srcsArray=($srcs)
++ local dirsBefore=
```

More Nix-specific logs can also be gotten by setting `NIX_DEBUG`:
```
$ nix-build -E 'with import <nixpkgs> {}; hello.overrideAttrs (old: { NIX_DEBUG = 1; })'
this derivation will be built:
  /nix/store/jhpig2710mvk62vyz0lh70zknjxlcxqs-hello-2.12.1.drv
building '/nix/store/jhpig2710mvk62vyz0lh70zknjxlcxqs-hello-2.12.1.drv'...
initial path: /nix/store/l8g5py3i39sq8afzi9vfmpw5igbqs84r-coreutils-9.1/bin:/nix/store/nwfyy893ql9ld0y249a5miwjb2kp15y8-findutils-4.9.0/bin:/nix/store/37gzj9sjgswm99bmgmr8r36ip19frfig-diffutils-3.9/bin:/nix/store/figk1iqjicv30sa9qnvbbzdb81bzsh1c-gnused-4.9/bin:/nix/store/4wwylhblws9na4ghmvsia38kimxl43g4-gnugrep-3.11/bin:/nix/store/rw2r8jqvbsmpq5kmgwvkv9pd833k9h3z-gawk-5.2.1/bin:/nix/store/g1ajd0l91n1ryyw779wlfhf73imbh4cf-gnutar-1.34/bin:/nix/store/4w0m22sx8yw9s1kw35f72cfak2qww8kh-gzip-1.12/bin:/nix/store/gsz5ca5ccqhdj31xv4z0pmdykrk3c81w-bzip2-1.0.8-bin/bin:/nix/store/9brwnhbqn9j6z1442hsq8vdsiv4dym9v-gnumake-4.4.1/bin:/nix/store/h6rxqqi4m0vipgvv9czpmwvifdjawb14-bash-5.2-p15/bin:/nix/store/lmvrwmdbb5a36m7mvhhkg275r8b8l5hl-patch-2.7.6/bin:/nix/store/1z5bqgk820x7xgn560kpk8znwh4z1irh-xz-5.4.3-bin/bin:/nix/store/h6y063nwq4bnzqmqsyq4aaygfyalkrxr-file-5.44/bin
```
