module Test.HTTPure.QuerySpec where

import Prelude

import Data.StrMap as StrMap
import Data.Tuple as Tuple
import Test.Spec as Spec

import HTTPure.Query as Query

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

readSpec :: TestHelpers.Test
readSpec = Spec.describe "read" do
  Spec.describe "with no query string" do
    Spec.it "is an empty StrMap" do
      req <- TestHelpers.mockRequest "" "/test" "" []
      Query.read req ?= StrMap.empty
  Spec.describe "with an empty query string" do
    Spec.it "is an empty StrMap" do
      req <- TestHelpers.mockRequest "" "/test?" "" []
      Query.read req ?= StrMap.empty
  Spec.describe "with a query parameter in the query string" do
    Spec.it "is a correct StrMap" do
      req <- TestHelpers.mockRequest "" "/test?a=b" "" []
      Query.read req ?= StrMap.singleton "a" "b"
  Spec.describe "with empty fields in the query string" do
    Spec.it "ignores the empty fields" do
      req <- TestHelpers.mockRequest "" "/test?&&a=b&&" "" []
      Query.read req ?= StrMap.singleton "a" "b"
  Spec.describe "with duplicated params" do
    Spec.it "takes the last param value" do
      req <- TestHelpers.mockRequest "" "/test?a=b&a=c" "" []
      Query.read req ?= StrMap.singleton "a" "c"
  Spec.describe "with empty params" do
    Spec.it "uses 'true' as the value" do
      req <- TestHelpers.mockRequest "" "/test?a" "" []
      Query.read req ?= StrMap.singleton "a" "true"
  Spec.describe "with complex params" do
    Spec.it "is the correct StrMap" do
      req <- TestHelpers.mockRequest "" "/test?&&a&b=c&b=d&&&e=f&g=&" "" []
      Query.read req ?= expectedComplexResult
  where
      expectedComplexResult =
        StrMap.fromFoldable
          [ Tuple.Tuple "a" "true"
          , Tuple.Tuple "b" "d"
          , Tuple.Tuple "e" "f"
          , Tuple.Tuple "g" "true"
          ]

querySpec :: TestHelpers.Test
querySpec = Spec.describe "Query" do
  readSpec
