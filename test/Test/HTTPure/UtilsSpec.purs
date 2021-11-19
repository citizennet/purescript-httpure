module Test.HTTPure.UtilsSpec where

import Test.Spec (describe, it)
import HTTPure.Utils (replacePlus)
import Test.HTTPure.TestHelpers (Test, (?=))

replacePlusSpec :: Test
replacePlusSpec =
  describe "replacePlus" do
    it "should replace all pluses" do
      replacePlus "foo+bar+baz" ?= "foo%20bar%20baz"

utilsSpec :: Test
utilsSpec =
  describe "Utils" do
    replacePlusSpec
