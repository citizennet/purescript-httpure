module Test.HTTPure.RequestSpec where

import Prelude

import Data.Tuple as Tuple
import Foreign.Object as Object
import Test.Spec as Spec

import HTTPure.Headers as Headers
import HTTPure.Method as Method
import HTTPure.Request as Request
import HTTPure.Version as Version

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

fromHTTPRequestSpec :: TestHelpers.Test
fromHTTPRequestSpec = Spec.describe "fromHTTPRequest" do
  Spec.it "contains the correct method" do
    mock <- mockRequest
    mock.method ?= Method.Post
  Spec.it "contains the correct path" do
    mock <- mockRequest
    mock.path ?= [ "test" ]
  Spec.it "contains the correct query" do
    mock <- mockRequest
    mock.query ?= Object.singleton "a" "b"
  Spec.it "contains the correct headers" do
    mock <- mockRequest
    mock.headers ?= Headers.headers mockHeaders
  Spec.it "contains the correct body" do
    mock <- mockRequest
    mock.body ?= "body"
  Spec.it "contains the correct httpVersion" do
    mock <- mockRequest
    mock.httpVersion ?= Version.HTTP1_1
  where
    mockHeaders = [ Tuple.Tuple "Test" "test" ]
    mockHTTPRequest =
      TestHelpers.mockRequest "1.1" "POST" "/test?a=b" "body" mockHeaders
    mockRequest = mockHTTPRequest >>= Request.fromHTTPRequest

fullPathSpec :: TestHelpers.Test
fullPathSpec = Spec.describe "fullPath" do
  Spec.describe "without query parameters" do
    Spec.it "is correct" do
      mock <- mockRequest "/foo/bar"
      Request.fullPath mock ?= "/foo/bar"
  Spec.describe "with empty path segments" do
    Spec.it "strips the empty segments" do
      mock <- mockRequest "//foo////bar/"
      Request.fullPath mock ?= "/foo/bar"
  Spec.describe "with only query parameters" do
    Spec.it "is correct" do
      mock <- mockRequest "?a=b&c=d"
      Request.fullPath mock ?= "/?a=b&c=d"
  Spec.describe "with only empty query parameters" do
    Spec.it "is has the default value of '' for the empty parameters" do
      mock <- mockRequest "?a"
      Request.fullPath mock ?= "/?a="
  Spec.describe "with query parameters that have special characters" do
    Spec.it "percent encodes query params" do
      mock <- mockRequest "?a=%3Fx%3Dtest"
      Request.fullPath mock ?= "/?a=%3Fx%3Dtest"
  Spec.describe "with empty query parameters" do
    Spec.it "strips out the empty arameters" do
      mock <- mockRequest "?a=b&&&"
      Request.fullPath mock ?= "/?a=b"
  Spec.describe "with a mix of segments and query parameters" do
    Spec.it "is correct" do
      mock <- mockRequest "/foo///bar/?&a=b&&c"
      Request.fullPath mock ?= "/foo/bar?a=b&c="
  where
    mockHTTPRequest path = TestHelpers.mockRequest "" "POST" path "body" []
    mockRequest path = mockHTTPRequest path >>= Request.fromHTTPRequest

requestSpec :: TestHelpers.Test
requestSpec = Spec.describe "Request" do
  fromHTTPRequestSpec
  fullPathSpec
