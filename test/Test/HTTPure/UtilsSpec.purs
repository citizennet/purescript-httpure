module Test.HTTPure.UtilsSpec where

import HTTPure.Utils (replacePlus)
import Test.HTTPure.TestHelpers (Test, (?=))
import Test.Spec (describe, it)

replacePlusSpec :: Test
replacePlusSpec =
  describe "replacePlus" do
    it "should replace all pluses" do
      replacePlus "foo+bar+baz" ?= "foo%20bar%20baz"

utilsSpec :: Test
utilsSpec =
  describe "Utils" do
    replacePlusSpec
