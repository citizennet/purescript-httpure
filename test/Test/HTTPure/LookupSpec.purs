module Test.HTTPure.LookupSpec where

import Prelude

import Data.Maybe as Maybe
import Data.StrMap as StrMap

import Test.Spec as Spec

import HTTPure.Lookup ((!!), (!@), (!?))

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

atSpec :: TestHelpers.Test
atSpec = Spec.describe "at" do
  Spec.describe "when the lookup returns a Just" do
    Spec.it "is the value inside the Just" do
      [ "one", "two", "three" ] !@ 1 ?= "two"
  Spec.describe "when the lookup returns a Nothing" do
    Spec.it "is mempty" do
      [ "one", "two", "three" ] !@ 4 ?= ""

hasSpec :: TestHelpers.Test
hasSpec = Spec.describe "has" do
  Spec.describe "when the lookup returns a Just" do
    Spec.it "is true" do
      [ "one", "two", "three" ] !? 1 ?= true
  Spec.describe "when the lookup returns a Nothing" do
    Spec.it "is false" do
      [ "one", "two", "three" ] !? 4 ?= false

lookupArraySpec :: TestHelpers.Test
lookupArraySpec = Spec.describe "lookupArray" do
  Spec.describe "when the index is in bounds" do
    Spec.it "is Just the value at the index" do
      [ "one", "two", "three" ] !! 1 ?= Maybe.Just "two"
  Spec.describe "when the index is out of bounds" do
    Spec.it "is Nothing" do
      (([ "one", "two", "three" ] !! 4) :: Maybe.Maybe String) ?= Maybe.Nothing

lookupStrMapSpec :: TestHelpers.Test
lookupStrMapSpec = Spec.describe "lookupStrMap" do
  Spec.describe "when the key is in the StrMap" do
    Spec.it "is Just the value at the given key" do
      mockStrMap !! "foo" ?= Maybe.Just "bar"
  Spec.describe "when the key is not in the StrMap" do
    Spec.it "is Nothing" do
      ((mockStrMap !! "baz") :: Maybe.Maybe String) ?= Maybe.Nothing
  where
    mockStrMap = StrMap.singleton "foo" "bar"

lookupSpec :: TestHelpers.Test
lookupSpec = Spec.describe "Lookup" do
  atSpec
  hasSpec
  lookupArraySpec
  lookupStrMapSpec
