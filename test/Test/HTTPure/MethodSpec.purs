module Test.HTTPure.MethodSpec where

import Prelude

import Test.Spec as Spec

import HTTPure.Method as Method

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

showSpec :: TestHelpers.Test
showSpec = Spec.describe "show" do
  Spec.describe "with a Get" do
    Spec.it "is 'Get'" do
      show Method.Get ?= "Get"
  Spec.describe "with a Post" do
    Spec.it "is 'Post'" do
      show Method.Post ?= "Post"
  Spec.describe "with a Put" do
    Spec.it "is 'Put'" do
      show Method.Put ?= "Put"
  Spec.describe "with a Delete" do
    Spec.it "is 'Delete'" do
      show Method.Delete ?= "Delete"
  Spec.describe "with a Head" do
    Spec.it "is 'Head'" do
      show Method.Head ?= "Head"
  Spec.describe "with a Connect" do
    Spec.it "is 'Connect'" do
      show Method.Connect ?= "Connect"
  Spec.describe "with a Options" do
    Spec.it "is 'Options'" do
      show Method.Options ?= "Options"
  Spec.describe "with a Trace" do
    Spec.it "is 'Trace'" do
      show Method.Trace ?= "Trace"
  Spec.describe "with a Patch" do
    Spec.it "is 'Patch'" do
      show Method.Patch ?= "Patch"

readSpec :: TestHelpers.Test
readSpec = Spec.describe "read" do
  Spec.describe "with a 'GET' Request" do
    Spec.it "is Get" do
      request <- TestHelpers.mockRequest "" "GET" "" "" []
      Method.read request ?= Method.Get

methodSpec :: TestHelpers.Test
methodSpec = Spec.describe "Method" do
  showSpec
  readSpec
