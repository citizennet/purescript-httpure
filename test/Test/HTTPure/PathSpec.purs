module Test.HTTPure.PathSpec where

import Prelude

import HTTPure.Path (read)
import Test.HTTPure.TestHelpers (Test, mockRequest, (?=))
import Test.Spec (describe, it)

readSpec :: Test
readSpec =
  describe "read" do
    describe "with a query string" do
      it "is just the path" do
        request <- mockRequest "" "GET" "test/path?blabla" "" []
        read request ?= [ "test", "path" ]
    describe "with no query string" do
      it "is the path" do
        request <- mockRequest "" "GET" "test/path" "" []
        read request ?= [ "test", "path" ]
    describe "with no segments" do
      it "is an empty array" do
        request <- mockRequest "" "GET" "" "" []
        read request ?= []
    describe "with empty segments" do
      it "strips the empty segments" do
        request <- mockRequest "" "GET" "//test//path///?query" "" []
        read request ?= [ "test", "path" ]
    describe "with percent encoded segments" do
      it "decodes percent encoding" do
        request <- mockRequest "" "GET" "/test%20path/%2Fthis" "" []
        read request ?= [ "test path", "/this" ]
      it "does not decode a plus sign" do
        request <- mockRequest "" "GET" "/test+path/this" "" []
        read request ?= [ "test+path", "this" ]

pathSpec :: Test
pathSpec =
  describe "Path" do
    readSpec
