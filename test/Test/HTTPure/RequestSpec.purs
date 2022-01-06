module Test.HTTPure.RequestSpec where

import Prelude
import Data.Tuple (Tuple(Tuple))
import Foreign.Object (singleton)
import Test.Spec (describe, it)
import HTTPure.Body (toString)
import HTTPure.ResponseHeaders (headers)
import HTTPure.Method (Method(Post))
import HTTPure.Request (fromHTTPRequest, fullPath)
import HTTPure.Version (Version(HTTP1_1))
import Test.HTTPure.TestHelpers (Test, (?=), convertToResponseHeader, mockRequest)

fromHTTPRequestSpec :: Test
fromHTTPRequestSpec =
  describe "fromHTTPRequest" do
    it "contains the correct method" do
      mock <- mockRequest'
      mock.method ?= Post
    it "contains the correct path" do
      mock <- mockRequest'
      mock.path ?= [ "test" ]
    it "contains the correct query" do
      mock <- mockRequest'
      mock.query ?= singleton "a" "b"
    it "contains the correct headers" do
      mock <- mockRequest'
      convertToResponseHeader mock.headers ?= headers mockHeaders
    it "contains the correct body" do
      mockBody <- mockRequest' >>= _.body >>> toString
      mockBody ?= "body"
    it "contains the correct httpVersion" do
      mock <- mockRequest'
      mock.httpVersion ?= HTTP1_1
  where
  mockHeaders = [ Tuple "Test" "test" ]

  mockHTTPRequest = mockRequest "1.1" "POST" "/test?a=b" "body" mockHeaders

  mockRequest' = mockHTTPRequest >>= fromHTTPRequest

fullPathSpec :: Test
fullPathSpec =
  describe "fullPath" do
    describe "without query parameters" do
      it "is correct" do
        mock <- mockRequest' "/foo/bar"
        fullPath mock ?= "/foo/bar"
    describe "with empty path segments" do
      it "strips the empty segments" do
        mock <- mockRequest' "//foo////bar/"
        fullPath mock ?= "/foo/bar"
    describe "with only query parameters" do
      it "is correct" do
        mock <- mockRequest' "?a=b&c=d"
        fullPath mock ?= "/?a=b&c=d"
    describe "with only empty query parameters" do
      it "is has the default value of '' for the empty parameters" do
        mock <- mockRequest' "?a"
        fullPath mock ?= "/?a="
    describe "with query parameters that have special characters" do
      it "percent encodes query params" do
        mock <- mockRequest' "?a=%3Fx%3Dtest"
        fullPath mock ?= "/?a=%3Fx%3Dtest"
    describe "with empty query parameters" do
      it "strips out the empty arameters" do
        mock <- mockRequest' "?a=b&&&"
        fullPath mock ?= "/?a=b"
    describe "with a mix of segments and query parameters" do
      it "is correct" do
        mock <- mockRequest' "/foo///bar/?&a=b&&c"
        fullPath mock ?= "/foo/bar?a=b&c="
  where
  mockHTTPRequest path = mockRequest "" "POST" path "body" []

  mockRequest' path = mockHTTPRequest path >>= fromHTTPRequest

requestSpec :: Test
requestSpec =
  describe "Request" do
    fromHTTPRequestSpec
    fullPathSpec
