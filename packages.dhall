let upstream =
      https://raw.githubusercontent.com/working-group-purescript-es/package-sets/main/packages.dhall
        sha256:08788d92ed3880cde1a311fd131c0c2c387ab5cca565c5193300613e54ecfedc

in  upstream
  with metadata.version = "v0.15.0"
