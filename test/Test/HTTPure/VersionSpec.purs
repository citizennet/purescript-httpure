module Test.HTTPure.VersionSpec where

import Prelude

import Test.Spec as Spec

import HTTPure.Version as Version

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

showSpec :: TestHelpers.Test
showSpec = Spec.describe "show" do
  Spec.describe "with an HTTP0_9" do
    Spec.it "is 'HTTP0_9'" do
      show Version.HTTP0_9 ?= "HTTP/0.9"
  Spec.describe "with an HTTP1_0" do
    Spec.it "is 'HTTP1_0'" do
      show Version.HTTP1_0 ?= "HTTP/1.0"
  Spec.describe "with an HTTP1_1" do
    Spec.it "is 'HTTP1_1'" do
      show Version.HTTP1_1 ?= "HTTP/1.1"
  Spec.describe "with an HTTP2_0" do
    Spec.it "is 'HTTP2_0'" do
      show Version.HTTP2_0 ?= "HTTP/2.0"
  Spec.describe "with an HTTP3_0" do
    Spec.it "is 'HTTP3_0'" do
      show Version.HTTP3_0 ?= "HTTP/3.0"
  Spec.describe "with an Other" do
    Spec.it "is 'Other'" do
      show (Version.Other "version") ?= "HTTP/version"

readSpec :: TestHelpers.Test
readSpec = Spec.describe "read" do
  Spec.describe "with an 'HTTP0_9' Request" do
    Spec.it "is HTTP0_9" do
      request <- TestHelpers.mockRequest "0.9" "" "" "" []
      Version.read request ?= Version.HTTP0_9
  Spec.describe "with an 'HTTP1_0' Request" do
    Spec.it "is HTTP1_0" do
      request <- TestHelpers.mockRequest "1.0" "" "" "" []
      Version.read request ?= Version.HTTP1_0
  Spec.describe "with an 'HTTP1_1' Request" do
    Spec.it "is HTTP1_1" do
      request <- TestHelpers.mockRequest "1.1" "" "" "" []
      Version.read request ?= Version.HTTP1_1
  Spec.describe "with an 'HTTP2_0' Request" do
    Spec.it "is HTTP2_0" do
      request <- TestHelpers.mockRequest "2.0" "" "" "" []
      Version.read request ?= Version.HTTP2_0
  Spec.describe "with an 'HTTP3_0' Request" do
    Spec.it "is HTTP3_0" do
      request <- TestHelpers.mockRequest "3.0" "" "" "" []
      Version.read request ?= Version.HTTP3_0
  Spec.describe "with an 'Other' Request" do
    Spec.it "is Other" do
      request <- TestHelpers.mockRequest "version" "" "" "" []
      Version.read request ?= Version.Other "version"

versionSpec :: TestHelpers.Test
versionSpec = Spec.describe "Version" do
  showSpec
  readSpec
