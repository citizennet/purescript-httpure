module Test.HTTPure.LookupSpec where

import Prelude

import Data.Maybe as Maybe
import Foreign.Object as Object

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

lookupFunctionSpec :: TestHelpers.Test
lookupFunctionSpec = Spec.describe "lookup" do
  Spec.describe "Array" do
    Spec.describe "when the index is in bounds" do
      Spec.it "is Just the value at the index" do
        [ "one", "two", "three" ] !! 1 ?= Maybe.Just "two"
    Spec.describe "when the index is out of bounds" do
      Spec.it "is Nothing" do
        (([ "one", "two", "three" ] !! 4) :: Maybe.Maybe String) ?= Maybe.Nothing
  Spec.describe "Map" do
    Spec.describe "when the key is in the Map" do
      Spec.it "is Just the value at the given key" do
        mockMap !! "foo" ?= Maybe.Just "bar"
    Spec.describe "when the key is not in the Map" do
      Spec.it "is Nothing" do
        ((mockMap !! "baz") :: Maybe.Maybe String) ?= Maybe.Nothing
  where
    mockMap = Object.singleton "foo" "bar"

lookupSpec :: TestHelpers.Test
lookupSpec = Spec.describe "Lookup" do
  atSpec
  hasSpec
  lookupFunctionSpec
