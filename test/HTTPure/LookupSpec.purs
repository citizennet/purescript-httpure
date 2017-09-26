module HTTPure.LookupSpec where

import Prelude

import Test.Spec as Spec

import HTTPure.Lookup ((!!))

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

lookupArraySpec :: SpecHelpers.Test
lookupArraySpec = Spec.describe "lookupArray" do
  Spec.describe "when the index is in bounds" do
    Spec.it "is the segment at the index" do
      [ "one", "two", "three" ] !! 1 ?= "two"
  Spec.describe "when the index is out of bounds" do
    Spec.it "is an empty monoid" do
      [ "one", "two", "three" ] !! 4 ?= ""

lookupSpec :: SpecHelpers.Test
lookupSpec = Spec.describe "Lookup" do
  lookupArraySpec
