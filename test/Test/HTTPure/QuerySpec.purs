module Test.HTTPure.QuerySpec where

import Prelude

import Data.Tuple as Tuple
import Foreign.Object as Object
import Test.Spec as Spec

import HTTPure.Query as Query

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

readSpec :: TestHelpers.Test
readSpec = Spec.describe "read" do
  Spec.describe "with no query string" do
    Spec.it "is an empty Map" do
      req <- TestHelpers.mockRequest "" "/test" "" []
      Query.read req ?= Object.empty
  Spec.describe "with an empty query string" do
    Spec.it "is an empty Map" do
      req <- TestHelpers.mockRequest "" "/test?" "" []
      Query.read req ?= Object.empty
  Spec.describe "with a query parameter in the query string" do
    Spec.it "is a correct Map" do
      req <- TestHelpers.mockRequest "" "/test?a=b" "" []
      Query.read req ?= Object.singleton "a" "b"
  Spec.describe "with empty fields in the query string" do
    Spec.it "ignores the empty fields" do
      req <- TestHelpers.mockRequest "" "/test?&&a=b&&" "" []
      Query.read req ?= Object.singleton "a" "b"
  Spec.describe "with duplicated params" do
    Spec.it "takes the last param value" do
      req <- TestHelpers.mockRequest "" "/test?a=b&a=c" "" []
      Query.read req ?= Object.singleton "a" "c"
  Spec.describe "with empty params" do
    Spec.it "uses '' as the value" do
      req <- TestHelpers.mockRequest "" "/test?a" "" []
      Query.read req ?= Object.singleton "a" ""
  Spec.describe "with complex params" do
    Spec.it "is the correct Map" do
      req <- TestHelpers.mockRequest "" "/test?&&a&b=c&b=d&&&e=f&g=&" "" []
      Query.read req ?= expectedComplexResult
  Spec.describe "with urlencoded params" do
    Spec.it "decodes valid keys and values" do
      req <- TestHelpers.mockRequest "" "/test?foo%20bar=%3Fx%3Dtest" "" []
      Query.read req ?= Object.singleton "foo bar" "?x=test"
    Spec.it "passes invalid keys and values through" do
      req <- TestHelpers.mockRequest "" "/test?%%=%C3" "" []
      Query.read req ?= Object.singleton "%%" "%C3"
    Spec.it "converts + to a space" do
      req <- TestHelpers.mockRequest "" "/test?foo=bar+baz" "" []
      Query.read req ?= Object.singleton "foo" "bar baz"
  where
      expectedComplexResult =
        Object.fromFoldable
          [ Tuple.Tuple "a" ""
          , Tuple.Tuple "b" "d"
          , Tuple.Tuple "e" "f"
          , Tuple.Tuple "g" ""
          ]

querySpec :: TestHelpers.Test
querySpec = Spec.describe "Query" do
  readSpec
