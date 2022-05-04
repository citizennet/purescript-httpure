let
  nivSrc = fetchTarball {
    url = "https://github.com/nmattia/niv/tarball/df49d53b71ad5b6b5847b32e5254924d60703c46";
    sha256 = "1j5p8mi1wi3pdcq0lfb881p97i232si07nb605dl92cjwnira88c";
  };
  sources = import "${nivSrc}/nix/sources.nix" {
    sourcesFile = ./sources.json;
  };
  niv = import nivSrc {};
in
  niv // sources
