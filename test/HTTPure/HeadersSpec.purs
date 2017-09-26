module HTTPure.HeadersSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.Tuple as Tuple
import Test.Spec as Spec

import HTTPure.Headers as Headers
import HTTPure.Lookup ((!!))

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

lookupSpec :: SpecHelpers.Test
lookupSpec = Spec.describe "lookup" do
  Spec.describe "when the string is in the header set" do
    Spec.describe "when searching with lowercase" do
      Spec.it "is the string" do
        mockHeaders !! "x-test" ?= "test"
    Spec.describe "when searching with uppercase" do
      Spec.it "is the string" do
        mockHeaders !! "X-Test" ?= "test"
  Spec.describe "when the string is not in the header set" do
    Spec.it "is an empty string" do
      (Headers.headers []) !!  "X-Test" ?= ""
  where
    mockHeaders = Headers.headers [Tuple.Tuple "x-test" "test"]

showSpec :: SpecHelpers.Test
showSpec = Spec.describe "show" do
  Spec.it "is a string representing the headers in HTTP format" do
    show mockHeaders ?= "Test1: test1\nTest2: test2\n\n"
  where
    mockHeaders =
      Headers.headers
        [ Tuple.Tuple "Test1" "test1"
        , Tuple.Tuple "Test2" "test2"
        ]

eqSpec :: SpecHelpers.Test
eqSpec = Spec.describe "eq" do
  Spec.describe "when the two Headers contain the same keys and values" do
    Spec.it "is true" do
      eq mockHeaders1 mockHeaders2 ?= true
  Spec.describe "when the two Headers contain different keys and values" do
    Spec.it "is false" do
      eq mockHeaders1 mockHeaders3 ?= false
  Spec.describe "when the one Headers contains additional keys and values" do
    Spec.it "is false" do
      eq mockHeaders1 mockHeaders4 ?= false
  where
    mockHeaders1 = Headers.headers [ Tuple.Tuple "Test1" "test1" ]
    mockHeaders2 = Headers.headers [ Tuple.Tuple "Test1" "test1" ]
    mockHeaders3 = Headers.headers [ Tuple.Tuple "Test2" "test2" ]
    mockHeaders4 =
      Headers.headers
        [ Tuple.Tuple "Test1" "test1"
        , Tuple.Tuple "Test2" "test2"
        ]

readSpec :: SpecHelpers.Test
readSpec = Spec.describe "read" do
  Spec.describe "with no headers" do
    Spec.it "is an empty StrMap" do
      request <- SpecHelpers.mockRequest "" "" "" []
      Headers.read request ?= Headers.headers []
  Spec.describe "with headers" do
    Spec.it "is an StrMap with the contents of the headers" do
      let testHeader = [Tuple.Tuple "X-Test" "test"]
      request <- SpecHelpers.mockRequest "" "" "" testHeader
      Headers.read request ?= Headers.headers testHeader

writeSpec :: SpecHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the headers to the response" do
    header <- EffClass.liftEff do
      mock <- SpecHelpers.mockResponse
      Headers.write mock $ Headers.headers [Tuple.Tuple "X-Test" "test"]
      pure $ SpecHelpers.getResponseHeader "X-Test" mock
    header ?= "test"

headersSpec :: SpecHelpers.Test
headersSpec = Spec.describe "Headers" do
  lookupSpec
  showSpec
  eqSpec
  readSpec
  writeSpec
