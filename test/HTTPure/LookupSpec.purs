module HTTPure.LookupSpec where

import Prelude

import Data.StrMap as StrMap

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

lookupStrMapSpec :: SpecHelpers.Test
lookupStrMapSpec = Spec.describe "lookupStrMap" do
  Spec.describe "when the key is in the StrMap" do
    Spec.it "is the value at the given key" do
      mockStrMap !! "foo" ?= "bar"
  Spec.describe "when the key is not in the StrMap" do
    Spec.it "is an empty monoid" do
      mockStrMap !! "baz" ?= ""
  where
    mockStrMap = StrMap.singleton "foo" "bar"

lookupSpec :: SpecHelpers.Test
lookupSpec = Spec.describe "Lookup" do
  lookupArraySpec
  lookupStrMapSpec
