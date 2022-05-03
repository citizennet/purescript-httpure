let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/21.11.tar.gz";
  }) { };

  # To update to a newer version of easy-purescript-nix, run:
  # nix-prefetch-git https://github.com/justinwoo/easy-purescript-nix
  #
  # Then, copy the resulting rev and sha256 here.
  pursPkgs = import (pkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "0ad5775c1e80cdd952527db2da969982e39ff592";
    sha256 = "0x53ads5v8zqsk4r1mfpzf5913byifdpv5shnvxpgw634ifyj1kg";
  }) { inherit pkgs; };

  build = pkgs.writeShellScriptBin "build" ''
    if [ "$1" == "test" ]
    then
      spago -x test.dhall build
    else
      spago build
    fi
  '';

  check-pulp = pkgs.writeShellScriptBin "check-pulp" ''
    bower install
    pulp build
  '';

  # Generate a new bower.json file from the spago.dhall file
  generate-bower = pkgs.writeShellScriptBin "generate-bower" ''
    spago bump-version patch --no-dry-run
  '';

  check = pkgs.writeShellScriptBin "check" "check-format && check-code";

  check-code = pkgs.writeShellScriptBin "check-code" "spago -x test.dhall test";

  check-format = pkgs.writeShellScriptBin "check-format" ''
    purs-tidy check src test docs
    nixfmt --check *.nix
  '';

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

  format = pkgs.writeShellScriptBin "format" ''
    purs-tidy format-in-place src test docs
    nixfmt *.nix
  '';

  repl = pkgs.writeShellScriptBin "repl" "spago repl";

in pkgs.mkShell {
  buildInputs = [
    pkgs.git

    pkgs.nodejs-16_x
    pkgs.nodePackages.bower
    pkgs.nixfmt

    pursPkgs.purescript
    pursPkgs.purs-tidy
    pursPkgs.spago
    pursPkgs.psa
    pursPkgs.pulp-16_0_0-0

    build
    check
    check-code
    check-format
    check-pulp
    generate-bower
    clean
    docs
    example
    format
    repl
  ];
}
