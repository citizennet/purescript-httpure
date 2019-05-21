{
  purescript ? "0.12.4",
  nixjs ? fetchTarball "https://github.com/cprussin/nixjs/tarball/release-19.03",
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
