{
  purescript ? "0.12.2",
  nixjs-version ? "0.0.7",
  nixjs ? fetchTarball "https://github.com/cprussin/nixjs/archive/${nixjs-version}.tar.gz",
  nixpkgs ? <nixpkgs>
}:

let
  nixjs-overlay = import nixjs { inherit purescript; };
  pkgs = import nixpkgs { overlays = [ nixjs-overlay ]; };
in

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.nodejs
    pkgs.yarn
    pkgs.purescript
    pkgs.psc-package
  ];
  shellHook = "export PATH=$PATH:$PWD/node_modules/.bin";
}
