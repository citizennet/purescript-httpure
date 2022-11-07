module Test.HTTPure.MultiHeadersSpec where

import Prelude

import Data.Array.NonEmpty (NonEmptyArray)
import Data.Map as Data.Map
import Data.Maybe (Maybe(..))
import Data.String.CaseInsensitive (CaseInsensitiveString(..))
import Data.Tuple (Tuple(..))
import Effect.Class (liftEffect)
import HTTPure.Lookup ((!!))
import HTTPure.MultiHeaders (MultiHeaders(..), empty, header, header', headers, read, write)
import Test.HTTPure.TestHelpers ((?=))
import Test.HTTPure.TestHelpers as TestHelpers
import Test.Spec (describe, it)

lookupSpec :: TestHelpers.Test
lookupSpec =
  describe "lookup" do
    describe "when the string is in the header set" do
      describe "when searching with lowercase" do
        it "is Just the string" do
          header "x-test" "test" !! "x-test" ?= Just (pure "test")
      describe "when searching with uppercase" do
        it "is Just the string" do
          header "x-test" "test" !! "X-Test" ?= Just (pure "test")
      describe "when the string is uppercase" do
        describe "when searching with lowercase" do
          it "is Just the string" do
            header "X-Test" "test" !! "x-test" ?= Just (pure "test")
        describe "when searching with uppercase" do
          it "is Just the string" do
            header "X-Test" "test" !! "X-Test" ?= Just (pure "test")
    describe "when the string is not in the header set" do
      it "is Nothing" do
        ((empty !! "X-Test") :: Maybe (NonEmptyArray String)) ?= Nothing

eqSpec :: TestHelpers.Test
eqSpec =
  describe "eq" do
    describe "when the two MultiHeaders contain the same keys and values" do
      it "is true" do
        header "Test1" "test1" == header "Test1" "test1" ?= true
    describe "when the two MultiHeaders contain different keys and values" do
      it "is false" do
        header "Test1" "test1" == header "Test2" "test2" ?= false
    describe "when the two MultiHeaders contain only different values" do
      it "is false" do
        header "Test1" "test1" == header "Test1" "test2" ?= false
    describe "when the one MultiHeaders contains additional keys and values" do
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
      it "appends the multiple values" do
        let mock = header "Test" "foo" <> header "Test" "bar"
        mock ?= header' "Test" (pure "foo" <> pure "bar")

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

writeSpec :: TestHelpers.Test
writeSpec =
  describe "write" do
    it "writes the headers to the response" do
      header <- liftEffect do
        mock <- TestHelpers.mockResponse
        write mock $ headers [ Tuple "X-Test" "test1", Tuple "X-Test" "test2" ]
        pure $ TestHelpers.getResponseMultiHeader "X-Test" mock
      header ?= [ "test1", "test2" ]

emptySpec :: TestHelpers.Test
emptySpec =
  describe "empty" do
    it "is an empty Map in an empty MultiHeaders" do
      empty ?= MultiHeaders Data.Map.empty

headerSpec :: TestHelpers.Test
headerSpec =
  describe "header" do
    it "creates a singleton MultiHeaders" do
      header "X-Test" "test" ?= MultiHeaders (Data.Map.singleton (CaseInsensitiveString "X-Test") (pure "test"))

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

multiHeadersSpec :: TestHelpers.Test
multiHeadersSpec =
  describe "MultiHeaders" do
    lookupSpec
    eqSpec
    appendSpec
    readSpec
    writeSpec
    emptySpec
    headerSpec
    headersFunctionSpec
