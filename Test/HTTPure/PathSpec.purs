module HTTPure.PathSpec where

import Prelude (pure, unit)

import Test.Spec as Spec

import HTTPure.SpecHelpers as SpecHelpers

pathSpec :: SpecHelpers.Test
pathSpec = Spec.describe "Path" do
  pure unit
