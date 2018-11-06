module Test.HTTPure.PathSpec where

import Prelude

import Test.Spec as Spec

import HTTPure.Path as Path

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

readSpec :: TestHelpers.Test
readSpec = Spec.describe "read" do
  Spec.describe "with a query string" do
    Spec.it "is just the path" do
      request <- TestHelpers.mockRequest "GET" "test/path?blabla" "" []
      Path.read request ?= [ "test", "path" ]
  Spec.describe "with no query string" do
    Spec.it "is the path" do
      request <- TestHelpers.mockRequest "GET" "test/path" "" []
      Path.read request ?= [ "test", "path" ]
  Spec.describe "with no segments" do
    Spec.it "is an empty array" do
      request <- TestHelpers.mockRequest "GET" "" "" []
      Path.read request ?= []
  Spec.describe "with empty segments" do
    Spec.it "strips the empty segments" do
      request <- TestHelpers.mockRequest "GET" "//test//path///?query" "" []
      Path.read request ?= [ "test", "path" ]
  Spec.describe "with percent encoded segments" do
    Spec.it "decodes percent encoding" do
      request <- TestHelpers.mockRequest "GET" "/test%20path/%2Fthis" "" []
      Path.read request ?= [ "test path", "/this" ]
    Spec.it "does not decode a plus sign" do
      request <- TestHelpers.mockRequest "GET" "/test+path/this" "" []
      Path.read request ?= [ "test+path", "this" ]

pathSpec :: TestHelpers.Test
pathSpec = Spec.describe "Path" do
  readSpec
