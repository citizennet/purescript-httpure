let conf = ./spago.dhall

in conf // {
  sources = conf.sources # [ "test/**/*.purs", "docs/Examples/**/*.purs" ],
  dependencies = conf.dependencies # [ "spec" ]
}