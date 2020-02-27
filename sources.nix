let
  nivSrc = fetchTarball {
    url = "https://github.com/nmattia/niv/tarball/4f038fc598d5494f5d16302270edc61ab2898c79";
    sha256 = "1dwfkd942wisccpsv0kf47abl0n17d9v4zasv4bm8lvy1dhv82ia";
  };
  sources = import "${nivSrc}/nix/sources.nix" {
    sourcesFile = ./sources.json;
  };
  niv = import nivSrc {};
in

niv // sources
