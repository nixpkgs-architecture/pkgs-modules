# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

let

# ---------------------------------------------------------------------------- #

  nixpkgs = builtins.getFlake "nixpkgs";
  system  = builtins.currentSystem;
  pkgsFor = builtins.getAttr system nixpkgs.legacyPackages;


# ---------------------------------------------------------------------------- #

  # Causes `nodePackages' to use `node@20'
  n20Overlay = final: prev: { nodejs = prev.nodejs-slim_20; };

  # Add a package that requires `node@20'
  myOverlay = final: prev: {
    nodePackages = prev.nodePackages.extend ( nfinal: nprev: let
      pkg-fun = { runCommand, nodejs, ... }: runCommand "bar" {
        meta.nodeVersion = nodejs.version;
      } ''
        case "$( ${nodejs}/bin/node --version; )" in
          v20.*) touch "$out"; ;;
          v*)    echo "v20 is required" >&2; exit 1; ;;
        esac
      '';
    in {
      bar0 = final.callPackage pkg-fun {};
      bar1 = prev.callPackage pkg-fun {};
      bar2 = pkg-fun { inherit (prev) nodejs; inherit (final) runCommand; };
      bar3 = pkg-fun { inherit (final) nodejs; inherit (prev) runCommand; };
      bar4 = pkg-fun { inherit (prev) nodejs runCommand; };
      bar5 = pkg-fun { inherit (final) nodejs runCommand; };
    } );
  };


# ---------------------------------------------------------------------------- #

  # Causes `nodePackages' to use `node@18'
  n18Overlay = final: prev: { nodejs = prev.nodejs-18_x; };

  # Add a package that requires `node@18'
  friendOverlay = final: prev: {
    nodePackages = prev.nodePackages.extend ( nfinal: nprev: let
      pkg-fun = { runCommand, nodejs, ... }: runCommand "quux" {
        meta.nodeVersion = nodejs.version;
      } ''
        case "$( ${nodejs}/bin/node --version; )" in
          v18.*) touch "$out"; ;;
          v*)    echo "v18 is required" >&2; exit 1; ;;
        esac
      '';
    in {
      quux0 = final.callPackage pkg-fun {};
      quux1 = prev.callPackage pkg-fun {};
      quux2 = pkg-fun { inherit (prev) nodejs; inherit (final) runCommand; };
      quux3 = pkg-fun { inherit (final) nodejs; inherit (prev) runCommand; };
      quux4 = pkg-fun { inherit (prev) nodejs runCommand; };
      quux5 = pkg-fun { inherit (final) nodejs runCommand; };
    } );
  };


# ---------------------------------------------------------------------------- #

  extractNodeVersions = let
    targets = [
      "bar0"  "bar1"  "bar2"  "bar3"  "bar4"  "bar5"
      "quux0" "quux1" "quux2" "quux3" "quux4" "quux5"
    ];
  in pkgs: let
    get = name: {
      inherit name;
      value = ( builtins.getAttr name pkgs.nodePackages ).meta.nodeVersion;
    };
  in builtins.listToAttrs ( map get targets );


# ---------------------------------------------------------------------------- #

  showNodeVersions = pkgs: let
    extracted = extractNodeVersions pkgs;
    showOne   = name: version: let
      spaces = if ( builtins.match "bar.*" name ) == null then " " else "  ";
    in name + ":" + spaces + "nodejs@" + version;
    strs = builtins.mapAttrs showOne extracted;
  in builtins.concatStringsSep "\n" ( builtins.attrValues strs );


# ---------------------------------------------------------------------------- #

  chainOverlays   = builtins.foldl' ( pkgs: pkgs.extend ) pkgsFor;
  composeOverlays = overlays:
    pkgsFor.extend ( nixpkgs.lib.composeManyExtensions overlays );

# ---------------------------------------------------------------------------- #

  pkgSets = {
    chained0  = chainOverlays   [n20Overlay myOverlay n18Overlay friendOverlay];
    chained1  = chainOverlays   [n18Overlay friendOverlay n20Overlay myOverlay];
    chained2  = chainOverlays   [friendOverlay n18Overlay myOverlay n20Overlay];
    chained3  = chainOverlays   [myOverlay n20Overlay friendOverlay n18Overlay];
    composed0 = composeOverlays [n20Overlay myOverlay n18Overlay friendOverlay];
    composed1 = composeOverlays [n18Overlay friendOverlay n20Overlay myOverlay];
    composed2 = composeOverlays [friendOverlay n18Overlay myOverlay n20Overlay];
    composed3 = composeOverlays [myOverlay n20Overlay friendOverlay n18Overlay];
  };

  versions = {
    nix = builtins.mapAttrs ( _: extractNodeVersions ) pkgSets;
    str = builtins.mapAttrs ( _: showNodeVersions ) pkgSets;
  };


# ---------------------------------------------------------------------------- #

in {

  inherit (nixpkgs) lib;
  inherit pkgsFor pkgSets versions;

  overlays = {
    inherit n20Overlay n18Overlay myOverlay friendOverlay;
  };
  util = {
    inherit chainOverlays composeOverlays extractNodeVersions showNodeVersions;
  };

  show = str: builtins.trace ( "\n" + str ) null;

  report = let
    reportOne = name: str: ''
      * ${name}
        - ${builtins.replaceStrings ["\n"] ["\n  - "] str}
    '';
    strs = builtins.mapAttrs reportOne versions.str;
  in builtins.concatStringsSep "\n" ( builtins.attrValues strs );

}

# ---------------------------------------------------------------------------- #
#
# Results
# -------
#   * chained0
#     - bar0:  nodejs@18.16.0
#     - bar1:  nodejs@18.16.0
#     - bar2:  nodejs@20.2.0
#     - bar3:  nodejs@18.16.0
#     - bar4:  nodejs@20.2.0
#     - bar5:  nodejs@18.16.0
#     - quux0: nodejs@18.16.0
#     - quux1: nodejs@18.16.0
#     - quux2: nodejs@18.16.0
#     - quux3: nodejs@18.16.0
#     - quux4: nodejs@18.16.0
#     - quux5: nodejs@18.16.0
#
#   * chained1
#     - bar0:  nodejs@20.2.0
#     - bar1:  nodejs@20.2.0
#     - bar2:  nodejs@20.2.0
#     - bar3:  nodejs@20.2.0
#     - bar4:  nodejs@20.2.0
#     - bar5:  nodejs@20.2.0
#     - quux0: nodejs@20.2.0
#     - quux1: nodejs@20.2.0
#     - quux2: nodejs@18.16.0
#     - quux3: nodejs@20.2.0
#     - quux4: nodejs@18.16.0
#     - quux5: nodejs@20.2.0
#
#   * chained2
#     - bar0:  nodejs@20.2.0
#     - bar1:  nodejs@20.2.0
#     - bar2:  nodejs@18.16.0
#     - bar3:  nodejs@20.2.0
#     - bar4:  nodejs@18.16.0
#     - bar5:  nodejs@20.2.0
#     - quux0: nodejs@20.2.0
#     - quux1: nodejs@20.2.0
#     - quux2: nodejs@18.16.0
#     - quux3: nodejs@20.2.0
#     - quux4: nodejs@18.16.0
#     - quux5: nodejs@20.2.0
#
#   * chained3
#     - bar0:  nodejs@18.16.0
#     - bar1:  nodejs@18.16.0
#     - bar2:  nodejs@18.16.0
#     - bar3:  nodejs@18.16.0
#     - bar4:  nodejs@18.16.0
#     - bar5:  nodejs@18.16.0
#     - quux0: nodejs@18.16.0
#     - quux1: nodejs@18.16.0
#     - quux2: nodejs@20.2.0
#     - quux3: nodejs@18.16.0
#     - quux4: nodejs@20.2.0
#     - quux5: nodejs@18.16.0
#
#   * composed0
#     - bar0:  nodejs@18.16.0
#     - bar1:  nodejs@18.16.0
#     - bar2:  nodejs@20.2.0
#     - bar3:  nodejs@18.16.0
#     - bar4:  nodejs@20.2.0
#     - bar5:  nodejs@18.16.0
#     - quux0: nodejs@18.16.0
#     - quux1: nodejs@18.16.0
#     - quux2: nodejs@18.16.0
#     - quux3: nodejs@18.16.0
#     - quux4: nodejs@18.16.0
#     - quux5: nodejs@18.16.0
#
#   * composed1
#     - bar0:  nodejs@20.2.0
#     - bar1:  nodejs@20.2.0
#     - bar2:  nodejs@20.2.0
#     - bar3:  nodejs@20.2.0
#     - bar4:  nodejs@20.2.0
#     - bar5:  nodejs@20.2.0
#     - quux0: nodejs@20.2.0
#     - quux1: nodejs@20.2.0
#     - quux2: nodejs@18.16.0
#     - quux3: nodejs@20.2.0
#     - quux4: nodejs@18.16.0
#     - quux5: nodejs@20.2.0
#
#   * composed2
#     - bar0:  nodejs@20.2.0
#     - bar1:  nodejs@20.2.0
#     - bar2:  nodejs@18.16.0
#     - bar3:  nodejs@20.2.0
#     - bar4:  nodejs@18.16.0
#     - bar5:  nodejs@20.2.0
#     - quux0: nodejs@20.2.0
#     - quux1: nodejs@20.2.0
#     - quux2: nodejs@18.16.0
#     - quux3: nodejs@20.2.0
#     - quux4: nodejs@18.16.0
#     - quux5: nodejs@20.2.0
#
#   * composed3
#     - bar0:  nodejs@18.16.0
#     - bar1:  nodejs@18.16.0
#     - bar2:  nodejs@18.16.0
#     - bar3:  nodejs@18.16.0
#     - bar4:  nodejs@18.16.0
#     - bar5:  nodejs@18.16.0
#     - quux0: nodejs@18.16.0
#     - quux1: nodejs@18.16.0
#     - quux2: nodejs@20.2.0
#     - quux3: nodejs@18.16.0
#     - quux4: nodejs@20.2.0
#     - quux5: nodejs@18.16.0
#
#
# ============================================================================ #
