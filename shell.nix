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
  pkgs = import sources.nixpkgs { overlays = [ niv-overlay ]; };
in

pkgs.mkShell {
  buildInputs = [
    pkgs.niv
    pkgs.git
    pkgs.nodejs
    pkgs.yarn
    pkgs.purescript
    pkgs.psc-package
  ];
  shellHook = "export PATH=$PATH:$PWD/node_modules/.bin";
}
