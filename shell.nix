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
  purs-tidy-overlay = pkgs: _: {
    inherit (import sources.easy-purescript-nix { inherit pkgs; }) purs-tidy;
  };
  unstable-packages-overlay = _: _: {
    inherit (import sources.nixpkgs-unstable {}) purescript;
  };
  pkgs = import sources.nixpkgs {
    overlays = [
      niv-overlay
      purs-tidy-overlay
      unstable-packages-overlay
    ];
  };
  build = pkgs.writeShellScriptBin "build" ''
    if [ "$1" == "test" ]
    then
      spago -x test.dhall build
    else
      spago build
    fi
  '';
  check = pkgs.writeShellScriptBin "check" "check-format && check-code";
  check-code = pkgs.writeShellScriptBin "check-code" "spago -x test.dhall test";
  check-format = pkgs.writeShellScriptBin "check-format" "purs-tidy check src test docs";
  clean = pkgs.writeShellScriptBin "clean" "rm -rf output .psci_modules .spago";
  docs = pkgs.writeShellScriptBin "docs" "spago docs";
  example = pkgs.writeShellScriptBin "example" ''
    if [ "$1" ]
    then
      spago -x test.dhall run --main Examples.$1.Main
    else
	    echo "Which example would you like to run?\n\nAvailable examples:"
      ls -1 ./docs/Examples | cat -n
	    read -rp " > " out
      if [ "$out" ]
      then
        $0 $(ls -1 ./docs/Examples | sed "''${out}q;d")
      fi
    fi
  '';
  format = pkgs.writeShellScriptBin "format" "purs-tidy format-in-place src test docs";
  repl = pkgs.writeShellScriptBin "repl" "spago repl";
in

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.niv
    pkgs.nodePackages.bower
    pkgs.nodePackages.pulp
    pkgs.nodejs
    pkgs.purescript
    pkgs.purs-tidy
    pkgs.spago
    build
    check
    check-code
    check-format
    clean
    docs
    example
    format
    repl
  ];
  shellHook = "export PATH=$PATH:$PWD/node_modules/.bin";
}
