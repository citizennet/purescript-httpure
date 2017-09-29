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
        Headers.header "x-test" "test" !! "x-test" ?= "test"
    Spec.describe "when searching with uppercase" do
      Spec.it "is the string" do
        Headers.header "x-test" "test" !! "X-Test" ?= "test"
  Spec.describe "when the string is not in the header set" do
    Spec.it "is an empty string" do
      Headers.empty !!  "X-Test" ?= ""

showSpec :: SpecHelpers.Test
showSpec = Spec.describe "show" do
  Spec.it "is a string representing the headers in HTTP format" do
    let mock = Headers.header "Test1" "1" <> Headers.header "Test2" "2"
    show mock ?= "Test1: 1\nTest2: 2\n\n"

eqSpec :: SpecHelpers.Test
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

appendSpec :: SpecHelpers.Test
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

readSpec :: SpecHelpers.Test
readSpec = Spec.describe "read" do
  Spec.describe "with no headers" do
    Spec.it "is an empty StrMap" do
      request <- SpecHelpers.mockRequest "" "" "" []
      Headers.read request ?= Headers.empty
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
      Headers.write mock $ Headers.header "X-Test" "test"
      pure $ SpecHelpers.getResponseHeader "X-Test" mock
    header ?= "test"

emptySpec :: SpecHelpers.Test
emptySpec = Spec.describe "empty" do
  Spec.it "is a empty StrMap in an empty Headers" do
    show Headers.empty ?= "\n"

headerSpec :: SpecHelpers.Test
headerSpec = Spec.describe "header" do
  Spec.it "creates a singleton Headers" do
    show (Headers.header "X-Test" "test") ?= "X-Test: test\n\n"

headersFunctionSpec :: SpecHelpers.Test
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

headersSpec :: SpecHelpers.Test
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
