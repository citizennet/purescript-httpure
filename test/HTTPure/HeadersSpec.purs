module HTTPure.HeadersSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec

import HTTPure.Headers as Headers

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

lookupSpec :: SpecHelpers.Test
lookupSpec = Spec.describe "lookup" do
  Spec.describe "when the string is in the header set" do
    Spec.describe "when searching with lowercase" do
      Spec.it "is the string" do
        Headers.lookup mockHeaders "x-test" ?= "test"
    Spec.describe "when searching with uppercase" do
      Spec.it "is the string" do
        Headers.lookup mockHeaders "X-Test" ?= "test"
  Spec.describe "when the string is not in the header set" do
    Spec.it "is an empty string" do
      Headers.lookup StrMap.empty "X-Test" ?= ""
  where
    mockHeaders = StrMap.singleton "x-test" "test"

writeSpec :: SpecHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the headers to the response" do
    header <- EffClass.liftEff do
      mock <- SpecHelpers.mockResponse
      Headers.write mock $ StrMap.singleton "X-Test" "test"
      pure $ SpecHelpers.getResponseHeader "X-Test" mock
    header ?= "test"

headersSpec :: SpecHelpers.Test
headersSpec = Spec.describe "Headers" do
  lookupSpec
  writeSpec
