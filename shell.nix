{ sources ? import ./sources.nix }:

let
  niv-overlay = self: _: {
    niv = self.symlinkJoin {
      name = "niv";
      paths = [ sources.niv ];
      buildInputs = [ self.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/niv \
          --add-flags "--sources-file ${toString ./sources.json}"
      '';
    };
  };
  pkgs-unstable = import sources.nixpkgs-unstable {};
  unstable-packages-overlay = _: _: {
    inherit (pkgs-unstable) purescript;
  };
  pkgs = import sources.nixpkgs {
    overlays = [
      niv-overlay
      unstable-packages-overlay
    ];
  };
in

pkgs.mkShell {
  buildInputs = [
    pkgs.niv
    pkgs.git
    pkgs.nodejs
    pkgs.yarn
    pkgs.purescript
  ];
  shellHook = "export PATH=$PATH:$PWD/node_modules/.bin";
}
