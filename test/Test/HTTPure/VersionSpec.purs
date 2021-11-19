module Test.HTTPure.VersionSpec where

import Prelude
import Test.Spec (describe, it)
import HTTPure.Version
  ( Version(HTTP0_9, HTTP1_0, HTTP1_1, HTTP2_0, HTTP3_0, Other)
  , read
  )
import Test.HTTPure.TestHelpers (Test, (?=), mockRequest)

showSpec :: Test
showSpec =
  describe "show" do
    describe "with an HTTP0_9" do
      it "is 'HTTP0_9'" do
        show HTTP0_9 ?= "HTTP/0.9"
    describe "with an HTTP1_0" do
      it "is 'HTTP1_0'" do
        show HTTP1_0 ?= "HTTP/1.0"
    describe "with an HTTP1_1" do
      it "is 'HTTP1_1'" do
        show HTTP1_1 ?= "HTTP/1.1"
    describe "with an HTTP2_0" do
      it "is 'HTTP2_0'" do
        show HTTP2_0 ?= "HTTP/2.0"
    describe "with an HTTP3_0" do
      it "is 'HTTP3_0'" do
        show HTTP3_0 ?= "HTTP/3.0"
    describe "with an Other" do
      it "is 'Other'" do
        show (Other "version") ?= "HTTP/version"

readSpec :: Test
readSpec =
  describe "read" do
    describe "with an 'HTTP0_9' Request" do
      it "is HTTP0_9" do
        request <- mockRequest "0.9" "" "" "" []
        read request ?= HTTP0_9
    describe "with an 'HTTP1_0' Request" do
      it "is HTTP1_0" do
        request <- mockRequest "1.0" "" "" "" []
        read request ?= HTTP1_0
    describe "with an 'HTTP1_1' Request" do
      it "is HTTP1_1" do
        request <- mockRequest "1.1" "" "" "" []
        read request ?= HTTP1_1
    describe "with an 'HTTP2_0' Request" do
      it "is HTTP2_0" do
        request <- mockRequest "2.0" "" "" "" []
        read request ?= HTTP2_0
    describe "with an 'HTTP3_0' Request" do
      it "is HTTP3_0" do
        request <- mockRequest "3.0" "" "" "" []
        read request ?= HTTP3_0
    describe "with an 'Other' Request" do
      it "is Other" do
        request <- mockRequest "version" "" "" "" []
        read request ?= Other "version"

versionSpec :: Test
versionSpec =
  describe "Version" do
    showSpec
    readSpec
