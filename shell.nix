{
  nixpkgs ? <nixpkgs>
}:

let
  pkgs = import nixpkgs {};
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
