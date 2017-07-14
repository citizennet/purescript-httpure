module HTTPure.BodySpec where

import Prelude (pure, unit)

import Test.Spec as Spec

import HTTPure.SpecHelpers as SpecHelpers

bodySpec :: SpecHelpers.Test
bodySpec = Spec.describe "Body" do
  pure unit
