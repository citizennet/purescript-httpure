module Test.HTTPure.HeadersSpec where

import Prelude

import Data.Map as Data.Map
import Data.Maybe (Maybe(..))
import Data.String.CaseInsensitive (CaseInsensitiveString(..))
import Data.Tuple (Tuple(..))
import Effect.Class (liftEffect)
import HTTPure.Headers (Headers(..), empty, header, headers, read, toString, write)
import HTTPure.Lookup ((!!))
import Test.HTTPure.TestHelpers ((?=))
import Test.HTTPure.TestHelpers as TestHelpers
import Test.Spec (describe, it)

lookupSpec :: TestHelpers.Test
lookupSpec =
  describe "lookup" do
    describe "when the string is in the header set" do
      describe "when searching with lowercase" do
        it "is Just the string" do
          header "x-test" "test" !! "x-test" ?= Just "test"
      describe "when searching with uppercase" do
        it "is Just the string" do
          header "x-test" "test" !! "X-Test" ?= Just "test"
      describe "when the string is uppercase" do
        describe "when searching with lowercase" do
          it "is Just the string" do
            header "X-Test" "test" !! "x-test" ?= Just "test"
        describe "when searching with uppercase" do
          it "is Just the string" do
            header "X-Test" "test" !! "X-Test" ?= Just "test"
    describe "when the string is not in the header set" do
      it "is Nothing" do
        ((empty !! "X-Test") :: Maybe String) ?= Nothing

eqSpec :: TestHelpers.Test
eqSpec =
  describe "eq" do
    describe "when the two Headers contain the same keys and values" do
      it "is true" do
        header "Test1" "test1" == header "Test1" "test1" ?= true
    describe "when the two Headers contain different keys and values" do
      it "is false" do
        header "Test1" "test1" == header "Test2" "test2" ?= false
    describe "when the two Headers contain only different values" do
      it "is false" do
        header "Test1" "test1" == header "Test1" "test2" ?= false
    describe "when the one Headers contains additional keys and values" do
      it "is false" do
        let mock = header "Test1" "1" <> header "Test2" "2"
        header "Test1" "1" == mock ?= false

appendSpec :: TestHelpers.Test
appendSpec =
  describe "append" do
    describe "when there are multiple keys" do
      it "appends the headers correctly" do
        let
          mock1 = header "Test1" "1" <> header "Test2" "2"
          mock2 = header "Test3" "3" <> header "Test4" "4"
          mock3 =
            headers
              [ Tuple "Test1" "1"
              , Tuple "Test2" "2"
              , Tuple "Test3" "3"
              , Tuple "Test4" "4"
              ]
        mock1 <> mock2 ?= mock3
    describe "when there is a duplicated key" do
      it "uses the last appended value" do
        let mock = header "Test" "foo" <> header "Test" "bar"
        mock ?= header "Test" "bar"

readSpec :: TestHelpers.Test
readSpec =
  describe "read" do
    describe "with no headers" do
      it "is an empty Map" do
        request <- TestHelpers.mockRequest "" "" "" "" []
        read request ?= empty
    describe "with headers" do
      it "is a Map with the contents of the headers" do
        let testHeader = [ Tuple "X-Test" "test" ]
        request <- TestHelpers.mockRequest "" "" "" "" testHeader
        read request ?= headers testHeader
    describe "with 'Set-Cookie' headers" do
      it "is a Map with the contents of the headers without any 'Set-Cookie' headers" do
        let testHeader = [ Tuple "X-Test" "test", Tuple "Set-Cookie" "foo", Tuple "set-cookie" "bar" ]
        let headers' = Headers $ Data.Map.singleton (CaseInsensitiveString "X-Test") "test"
        request <- TestHelpers.mockRequest "" "" "" "" testHeader
        read request ?= headers'

writeSpec :: TestHelpers.Test
writeSpec =
  describe "write" do
    it "writes the headers to the response" do
      header <- liftEffect do
        mock <- TestHelpers.mockResponse
        write mock $ header "X-Test" "test"
        pure $ TestHelpers.getResponseHeader "X-Test" mock
      header ?= "test"

emptySpec :: TestHelpers.Test
emptySpec =
  describe "empty" do
    it "is an empty Map in an empty Headers" do
      empty ?= Headers Data.Map.empty

headerSpec :: TestHelpers.Test
headerSpec =
  describe "header" do
    it "creates a singleton Headers" do
      header "X-Test" "test" ?= Headers (Data.Map.singleton (CaseInsensitiveString "X-Test") "test")

headersFunctionSpec :: TestHelpers.Test
headersFunctionSpec =
  describe "headers" do
    it "is equivalent to using header with <>" do
      let
        expected = header "X-Test-1" "1" <> header "X-Test-2" "2"
        test = headers
          [ Tuple "X-Test-1" "1"
          , Tuple "X-Test-2" "2"
          ]
      test ?= expected

toStringSpec :: TestHelpers.Test
toStringSpec =
  describe "toString" do
    it "is a string representing the headers in HTTP format" do
      let mock = header "Test1" "1" <> header "Test2" "2"
      toString mock ?= "Test1: 1\nTest2: 2\n\n"

headersSpec :: TestHelpers.Test
headersSpec =
  describe "Headers" do
    lookupSpec
    eqSpec
    appendSpec
    readSpec
    writeSpec
    emptySpec
    headerSpec
    headersFunctionSpec
    toStringSpec
