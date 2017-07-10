module HTTPure.HTTPureMSpec where

import Prelude (pure, unit, ($))

import Test.Spec as Spec

import HTTPure.SpecHelpers as SpecHelpers

httpureMSpec :: SpecHelpers.Test
httpureMSpec = Spec.describe "HTTPureM" $
  pure unit
