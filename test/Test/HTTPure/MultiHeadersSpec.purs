module Test.HTTPure.MultiHeadersSpec where

import Prelude

import Data.Array.NonEmpty (NonEmptyArray)
import Data.Map as Data.Map
import Data.Maybe (Maybe(..))
import Data.String.CaseInsensitive (CaseInsensitiveString(..))
import Data.Tuple (Tuple(..))
import Effect.Class (liftEffect)
import HTTPure.Lookup ((!!))
import HTTPure.MultiHeaders (MultiHeaders(..))
import HTTPure.MultiHeaders as HTTPure.MultiHeaders
import Test.HTTPure.TestHelpers ((?=))
import Test.HTTPure.TestHelpers as TestHelpers
import Test.Spec as Test.Spec

lookupSpec :: TestHelpers.Test
lookupSpec =
  Test.Spec.describe "lookup" do
    Test.Spec.describe "when the string is in the header set" do
      Test.Spec.describe "when searching with lowercase" do
        Test.Spec.it "is Just the string" do
          HTTPure.MultiHeaders.header "x-test" "test" !! "x-test" ?= Just (pure "test")
      Test.Spec.describe "when searching with uppercase" do
        Test.Spec.it "is Just the string" do
          HTTPure.MultiHeaders.header "x-test" "test" !! "X-Test" ?= Just (pure "test")
      Test.Spec.describe "when the string is uppercase" do
        Test.Spec.describe "when searching with lowercase" do
          Test.Spec.it "is Just the string" do
            HTTPure.MultiHeaders.header "X-Test" "test" !! "x-test" ?= Just (pure "test")
        Test.Spec.describe "when searching with uppercase" do
          Test.Spec.it "is Just the string" do
            HTTPure.MultiHeaders.header "X-Test" "test" !! "X-Test" ?= Just (pure "test")
    Test.Spec.describe "when the string is not in the header set" do
      Test.Spec.it "is Nothing" do
        ((HTTPure.MultiHeaders.empty !! "X-Test") :: Maybe (NonEmptyArray String)) ?= Nothing

eqSpec :: TestHelpers.Test
eqSpec =
  Test.Spec.describe "eq" do
    Test.Spec.describe "when the two MultiHeaders contain the same keys and values" do
      Test.Spec.it "is true" do
        HTTPure.MultiHeaders.header "Test1" "test1" == HTTPure.MultiHeaders.header "Test1" "test1" ?= true
    Test.Spec.describe "when the two MultiHeaders contain different keys and values" do
      Test.Spec.it "is false" do
        HTTPure.MultiHeaders.header "Test1" "test1" == HTTPure.MultiHeaders.header "Test2" "test2" ?= false
    Test.Spec.describe "when the two MultiHeaders contain only different values" do
      Test.Spec.it "is false" do
        HTTPure.MultiHeaders.header "Test1" "test1" == HTTPure.MultiHeaders.header "Test1" "test2" ?= false
    Test.Spec.describe "when the one MultiHeaders contains additional keys and values" do
      Test.Spec.it "is false" do
        let mock = HTTPure.MultiHeaders.header "Test1" "1" <> HTTPure.MultiHeaders.header "Test2" "2"
        HTTPure.MultiHeaders.header "Test1" "1" == mock ?= false

appendSpec :: TestHelpers.Test
appendSpec =
  Test.Spec.describe "append" do
    Test.Spec.describe "when there are multiple keys" do
      Test.Spec.it "appends the headers correctly" do
        let
          mock1 = HTTPure.MultiHeaders.header "Test1" "1" <> HTTPure.MultiHeaders.header "Test2" "2"
          mock2 = HTTPure.MultiHeaders.header "Test3" "3" <> HTTPure.MultiHeaders.header "Test4" "4"
          mock3 =
            HTTPure.MultiHeaders.headers
              [ Tuple "Test1" "1"
              , Tuple "Test2" "2"
              , Tuple "Test3" "3"
              , Tuple "Test4" "4"
              ]
        mock1 <> mock2 ?= mock3
    Test.Spec.describe "when there is a duplicated key" do
      Test.Spec.it "appends the multiple values" do
        let mock = HTTPure.MultiHeaders.header "Test" "foo" <> HTTPure.MultiHeaders.header "Test" "bar"
        mock ?= HTTPure.MultiHeaders.header' "Test" (pure "foo" <> pure "bar")

readSpec :: TestHelpers.Test
readSpec =
  Test.Spec.describe "read" do
    Test.Spec.describe "with no headers" do
      Test.Spec.it "is an empty Map" do
        request <- TestHelpers.mockRequest "" "" "" "" []
        HTTPure.MultiHeaders.read request ?= HTTPure.MultiHeaders.empty
    Test.Spec.describe "with headers" do
      Test.Spec.it "is a Map with the contents of the headers" do
        let testHeader = [ Tuple "X-Test" "test", Tuple "X-Foo" "bar" ]
        request <- TestHelpers.mockRequest "" "" "" "" testHeader
        HTTPure.MultiHeaders.read request ?= HTTPure.MultiHeaders.headers testHeader
    Test.Spec.describe "with duplicate headers" do
      Test.Spec.it "is a Map with the contents of the headers" do
        let testHeader = [ Tuple "X-Test" "test1", Tuple "X-Test" "test2" ]
        request <- TestHelpers.mockRequest "" "" "" "" testHeader
        HTTPure.MultiHeaders.read request ?= HTTPure.MultiHeaders.headers testHeader

writeSpec :: TestHelpers.Test
writeSpec =
  Test.Spec.describe "write" do
    Test.Spec.it "writes the headers to the response" do
      header <- liftEffect do
        mock <- TestHelpers.mockResponse
        HTTPure.MultiHeaders.write mock $ HTTPure.MultiHeaders.headers [ Tuple "X-Test" "test1", Tuple "X-Test" "test2" ]
        pure $ TestHelpers.getResponseMultiHeader "X-Test" mock
      header ?= [ "test1", "test2" ]

emptySpec :: TestHelpers.Test
emptySpec =
  Test.Spec.describe "empty" do
    Test.Spec.it "is an empty Map in an empty MultiHeaders" do
      HTTPure.MultiHeaders.empty ?= MultiHeaders Data.Map.empty

headerSpec :: TestHelpers.Test
headerSpec =
  Test.Spec.describe "header" do
    Test.Spec.it "creates a singleton MultiHeaders" do
      HTTPure.MultiHeaders.header "X-Test" "test" ?= MultiHeaders (Data.Map.singleton (CaseInsensitiveString "X-Test") (pure "test"))

headersFunctionSpec :: TestHelpers.Test
headersFunctionSpec =
  Test.Spec.describe "headers" do
    Test.Spec.it "is equivalent to using header with <>" do
      let
        expected = HTTPure.MultiHeaders.header "X-Test-1" "1" <> HTTPure.MultiHeaders.header "X-Test-2" "2"
        test = HTTPure.MultiHeaders.headers
          [ Tuple "X-Test-1" "1"
          , Tuple "X-Test-2" "2"
          ]
      test ?= expected

toStringSpec :: TestHelpers.Test
toStringSpec =
  Test.Spec.describe "toString" do
    Test.Spec.it "is a string representing the headers in HTTP format" do
      let mock = HTTPure.MultiHeaders.header "Test1" "1" <> HTTPure.MultiHeaders.header "Test2" "2"
      HTTPure.MultiHeaders.toString mock ?= "Test1: 1\nTest2: 2\n\n"
    Test.Spec.it "separates duplicate headers with a comma" do
      let
        mock =
          HTTPure.MultiHeaders.header "Test1" "1"
            <> HTTPure.MultiHeaders.header "Test1" "2"
            <> HTTPure.MultiHeaders.header "Test2" "2"
      HTTPure.MultiHeaders.toString mock ?= "Test1: 1, 2\nTest2: 2\n\n"
    Test.Spec.it "separates duplicate 'Set-Cookie' headers with a semicolon" do
      let
        mock =
          HTTPure.MultiHeaders.header "Test1" "1"
            <> HTTPure.MultiHeaders.header "Set-Cookie" "1"
            <> HTTPure.MultiHeaders.header "Set-Cookie" "2"
      HTTPure.MultiHeaders.toString mock ?= "Set-Cookie: 1; 2\nTest1: 1\n\n"

multiHeadersSpec :: TestHelpers.Test
multiHeadersSpec =
  Test.Spec.describe "MultiHeaders" do
    lookupSpec
    eqSpec
    appendSpec
    readSpec
    writeSpec
    emptySpec
    headerSpec
    headersFunctionSpec
    toStringSpec
