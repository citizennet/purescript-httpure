module Test.HTTPure.HeadersSpec where

import Prelude

import Effect.Class as EffectClass
import Data.Maybe as Maybe
import Data.Tuple as Tuple
import Test.Spec as Spec

import HTTPure.Headers as Headers
import HTTPure.Lookup ((!!))

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

lookupSpec :: TestHelpers.Test
lookupSpec = Spec.describe "lookup" do
  Spec.describe "when the string is in the header set" do
    Spec.describe "when searching with lowercase" do
      Spec.it "is Just the string" do
        Headers.header "x-test" "test" !! "x-test" ?= Maybe.Just "test"
    Spec.describe "when searching with uppercase" do
      Spec.it "is Just the string" do
        Headers.header "x-test" "test" !! "X-Test" ?= Maybe.Just "test"
  Spec.describe "when the string is not in the header set" do
    Spec.it "is Nothing" do
      ((Headers.empty !! "X-Test") :: Maybe.Maybe String) ?= Maybe.Nothing

showSpec :: TestHelpers.Test
showSpec = Spec.describe "show" do
  Spec.it "is a string representing the headers in HTTP format" do
    let mock = Headers.header "Test1" "1" <> Headers.header "Test2" "2"
    show mock ?= "Test1: 1\nTest2: 2\n\n"

eqSpec :: TestHelpers.Test
eqSpec = Spec.describe "eq" do
  Spec.describe "when the two Headers contain the same keys and values" do
    Spec.it "is true" do
      Headers.header "Test1" "test1" == Headers.header "Test1" "test1" ?= true
  Spec.describe "when the two Headers contain different keys and values" do
    Spec.it "is false" do
      Headers.header "Test1" "test1" == Headers.header "Test2" "test2" ?= false
  Spec.describe "when the two Headers contain only different values" do
    Spec.it "is false" do
      Headers.header "Test1" "test1" == Headers.header "Test1" "test2" ?= false
  Spec.describe "when the one Headers contains additional keys and values" do
    Spec.it "is false" do
      let mock = Headers.header "Test1" "1" <> Headers.header "Test2" "2"
      Headers.header "Test1" "1" == mock ?= false

appendSpec :: TestHelpers.Test
appendSpec = Spec.describe "append" do
  Spec.describe "when there are multiple keys" do
    Spec.it "appends the headers correctly" do
      let mock1 = Headers.header "Test1" "1" <> Headers.header "Test2" "2"
      let mock2 = Headers.header "Test3" "3" <> Headers.header "Test4" "4"
      let mock3 = Headers.headers
                    [ Tuple.Tuple "Test1" "1"
                    , Tuple.Tuple "Test2" "2"
                    , Tuple.Tuple "Test3" "3"
                    , Tuple.Tuple "Test4" "4"
                    ]
      mock1 <> mock2 ?= mock3
  Spec.describe "when there is a duplicated key" do
    Spec.it "uses the last appended value" do
      let mock = Headers.header "Test" "foo" <> Headers.header "Test" "bar"
      mock ?= Headers.header "Test" "bar"

readSpec :: TestHelpers.Test
readSpec = Spec.describe "read" do
  Spec.describe "with no headers" do
    Spec.it "is an empty Map" do
      request <- TestHelpers.mockRequest "" "" "" []
      Headers.read request ?= Headers.empty
  Spec.describe "with headers" do
    Spec.it "is a Map with the contents of the headers" do
      let testHeader = [Tuple.Tuple "X-Test" "test"]
      request <- TestHelpers.mockRequest "" "" "" testHeader
      Headers.read request ?= Headers.headers testHeader

writeSpec :: TestHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the headers to the response" do
    header <- EffectClass.liftEffect do
      mock <- TestHelpers.mockResponse
      Headers.write mock $ Headers.header "X-Test" "test"
      pure $ TestHelpers.getResponseHeader "X-Test" mock
    header ?= "test"

emptySpec :: TestHelpers.Test
emptySpec = Spec.describe "empty" do
  Spec.it "is an empty Map in an empty Headers" do
    show Headers.empty ?= "\n"

headerSpec :: TestHelpers.Test
headerSpec = Spec.describe "header" do
  Spec.it "creates a singleton Headers" do
    show (Headers.header "X-Test" "test") ?= "X-Test: test\n\n"

headersFunctionSpec :: TestHelpers.Test
headersFunctionSpec = Spec.describe "headers" do
  Spec.it "is equivalent to using Headers.header with <>" do
    test ?= expected
  where
    test =
      Headers.headers
        [ Tuple.Tuple "X-Test-1" "1"
        , Tuple.Tuple "X-Test-2" "2"
        ]
    expected = Headers.header "X-Test-1" "1" <> Headers.header "X-Test-2" "2"

headersSpec :: TestHelpers.Test
headersSpec = Spec.describe "Headers" do
  lookupSpec
  showSpec
  eqSpec
  appendSpec
  readSpec
  writeSpec
  emptySpec
  headerSpec
  headersFunctionSpec
