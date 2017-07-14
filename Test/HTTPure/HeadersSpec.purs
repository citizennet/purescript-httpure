module HTTPure.HeadersSpec where

import Prelude (pure, unit)

import Test.Spec as Spec

import HTTPure.SpecHelpers as SpecHelpers

headersSpec :: SpecHelpers.Test
headersSpec = Spec.describe "Headers" do
  pure unit
