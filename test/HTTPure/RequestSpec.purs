module HTTPure.RequestSpec where

import Prelude

import Data.Tuple as Tuple
import Data.StrMap as StrMap
import Test.Spec as Spec

import HTTPure.Headers as Headers
import HTTPure.Method as Method
import HTTPure.Request as Request

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

fromHTTPRequestSpec :: SpecHelpers.Test
fromHTTPRequestSpec = Spec.describe "fromHTTPRequest" do
  Spec.it "contains the correct method" do
    mock <- mockRequest
    mock.method ?= Method.Post
  Spec.it "contains the correct path" do
    mock <- mockRequest
    mock.path ?= [ "test" ]
  Spec.it "contains the correct query" do
    mock <- mockRequest
    mock.query ?= StrMap.singleton "a" "b"
  Spec.it "contains the correct headers" do
    mock <- mockRequest
    mock.headers ?= Headers.headers mockHeaders
  Spec.it "contains the correct body" do
    mock <- mockRequest
    mock.body ?= "body"
  where
    mockHeaders = [ Tuple.Tuple "Test" "test" ]
    mockHTTPRequest =
      SpecHelpers.mockRequest "POST" "/test?a=b" "body" mockHeaders
    mockRequest = mockHTTPRequest >>= Request.fromHTTPRequest

requestSpec :: SpecHelpers.Test
requestSpec = Spec.describe "Request" do
  fromHTTPRequestSpec
