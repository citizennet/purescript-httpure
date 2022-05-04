module Test.HTTPure.LookupSpec where

import Prelude

import Data.Maybe (Maybe(Nothing, Just))
import Foreign.Object (singleton)
import HTTPure.Lookup ((!!), (!?), (!@))
import Test.HTTPure.TestHelpers (Test, (?=))
import Test.Spec (describe, it)

atSpec :: Test
atSpec =
  describe "at" do
    describe "when the lookup returns a Just" do
      it "is the value inside the Just" do
        [ "one", "two", "three" ] !@ 1 ?= "two"
    describe "when the lookup returns a Nothing" do
      it "is mempty" do
        [ "one", "two", "three" ] !@ 4 ?= ""

hasSpec :: Test
hasSpec =
  describe "has" do
    describe "when the lookup returns a Just" do
      it "is true" do
        [ "one", "two", "three" ] !? 1 ?= true
    describe "when the lookup returns a Nothing" do
      it "is false" do
        [ "one", "two", "three" ] !? 4 ?= false

lookupFunctionSpec :: Test
lookupFunctionSpec =
  describe "lookup" do
    describe "Array" do
      describe "when the index is in bounds" do
        it "is Just the value at the index" do
          [ "one", "two", "three" ] !! 1 ?= Just "two"
      describe "when the index is out of bounds" do
        it "is Nothing" do
          (([ "one", "two", "three" ] !! 4) :: Maybe String) ?= Nothing
    describe "Map" do
      describe "when the key is in the Map" do
        it "is Just the value at the given key" do
          let mockMap = singleton "foo" "bar"
          mockMap !! "foo" ?= Just "bar"
      describe "when the key is not in the Map" do
        it "is Nothing" do
          let mockMap = singleton "foo" "bar"
          ((mockMap !! "baz") :: Maybe String) ?= Nothing

lookupSpec :: Test
lookupSpec =
  describe "Lookup" do
    atSpec
    hasSpec
    lookupFunctionSpec
