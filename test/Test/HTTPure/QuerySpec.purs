module Test.HTTPure.QuerySpec where

import Prelude

import Data.Tuple (Tuple(Tuple))
import Foreign.Object (empty, fromFoldable, singleton)
import HTTPure.Query (read)
import Test.HTTPure.TestHelpers (Test, mockRequest, (?=))
import Test.Spec (describe, it)

readSpec :: Test
readSpec =
  describe "read" do
    describe "with no query string" do
      it "is an empty Map" do
        req <- mockRequest "" "" "/test" "" []
        read req ?= empty
    describe "with an empty query string" do
      it "is an empty Map" do
        req <- mockRequest "" "" "/test?" "" []
        read req ?= empty
    describe "with a query parameter in the query string" do
      it "is a correct Map" do
        req <- mockRequest "" "" "/test?a=b" "" []
        read req ?= singleton "a" "b"
    describe "with empty fields in the query string" do
      it "ignores the empty fields" do
        req <- mockRequest "" "" "/test?&&a=b&&" "" []
        read req ?= singleton "a" "b"
    describe "with duplicated params" do
      it "takes the last param value" do
        req <- mockRequest "" "" "/test?a=b&a=c" "" []
        read req ?= singleton "a" "c"
    describe "with empty params" do
      it "uses '' as the value" do
        req <- mockRequest "" "" "/test?a" "" []
        read req ?= singleton "a" ""
    describe "with complex params" do
      it "is the correct Map" do
        req <- mockRequest "" "" "/test?&&a&b=c&b=d&&&e=f&g=&" "" []
        let
          expectedComplexResult =
            fromFoldable
              [ Tuple "a" ""
              , Tuple "b" "d"
              , Tuple "e" "f"
              , Tuple "g" ""
              ]
        read req ?= expectedComplexResult
    describe "with urlencoded params" do
      it "decodes valid keys and values" do
        req <- mockRequest "" "" "/test?foo%20bar=%3Fx%3Dtest" "" []
        read req ?= singleton "foo bar" "?x=test"
      it "passes invalid keys and values through" do
        req <- mockRequest "" "" "/test?%%=%C3" "" []
        read req ?= singleton "%%" "%C3"
      it "converts + to a space" do
        req <- mockRequest "" "" "/test?foo=bar+baz" "" []
        read req ?= singleton "foo" "bar baz"

querySpec :: Test
querySpec =
  describe "Query" do
    readSpec
