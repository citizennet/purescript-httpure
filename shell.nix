{
  sources ? import ./sources.nix,
  nixpkgs ? sources.nixpkgs,
  easy-purescript-nix ? sources.easy-purescript-nix,
  niv ? sources.niv,
  alejandra ? sources.alejandra,
}: let
  niv-overlay = self: super: {
    niv = self.symlinkJoin {
      name = "niv";
      paths = [super.niv];
      buildInputs = [self.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/niv \
          --add-flags "--sources-file ${toString ./sources.json}"
      '';
    };
  };

  easy-purescript-nix-overlay = pkgs: _: {
    inherit (import easy-purescript-nix {inherit pkgs;}) purescript purs-tidy spago psa pulp-16_0_0-0;
  };

  alejandra-overlay = self: _: {
    alejandra = (import alejandra)."${self.system}";
  };

  pkgs = import nixpkgs {
    overlays = [
      niv-overlay
      easy-purescript-nix-overlay
      alejandra-overlay
    ];
  };

  scripts = pkgs.symlinkJoin {
    name = "scripts";
    paths = pkgs.lib.mapAttrsToList pkgs.writeShellScriptBin {
      build = "spago -x \${1:-spago}.dhall build";
      check = "check-format && check-code && check-pulp";
      check-code = "spago -x test.dhall test";
      check-format = "check-format-purescript && check-format-nix";
      check-format-nix = "alejandra --check *.nix";
      check-format-purescript = "purs-tidy check src test docs";
      check-pulp = "bower install && pulp build";
      clean = "rm -rf output .psci_modules .spago";
      example = ''
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
      format = "format-purescript && format-nix";
      format-nix = "alejandra *.nix";
      format-purescript = "purs-tidy format-in-place src test docs";
      generate-bower = "spago bump-version patch --no-dry-run";
      generate-docs = "spago docs";
      repl = "spago repl";
    };
  };
in
  pkgs.mkShell {
    buildInputs = [
      pkgs.alejandra
      pkgs.git
      pkgs.niv
      pkgs.nodePackages.bower
      pkgs.nodejs-16_x
      pkgs.psa
      pkgs.pulp-16_0_0-0
      pkgs.purescript
      pkgs.purs-tidy
      pkgs.spago
      scripts
    ];
  }
