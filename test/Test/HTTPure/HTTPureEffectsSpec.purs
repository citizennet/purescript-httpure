module Test.HTTPure.HTTPureEffectsSpec where

import Prelude

import Test.Spec as Spec

import Test.HTTPure.TestHelpers as TestHelpers

httpureEffectsSpec :: TestHelpers.Test
httpureEffectsSpec = Spec.describe "HTTPureEffects" do
  pure unit
