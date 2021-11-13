let conf = ./spago.dhall

in conf // {
  sources = conf.sources # [ "test/**/*.purs", "docs/Examples/**/*.purs" ],
  dependencies = conf.dependencies # [
  , "exceptions"
  , "lists"
  , "node-child-process"
  , "node-fs-aff"
  , "spec"
  , "transformers"
  , "unsafe-coerce" 
  ]
}
