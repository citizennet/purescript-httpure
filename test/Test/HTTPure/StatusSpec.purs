module Test.HTTPure.StatusSpec where

import Prelude
import Effect.Class (liftEffect)
import Test.Spec (describe, it)
import HTTPure.Status (write)
import Test.HTTPure.TestHelpers (Test, (?=), mockResponse, getResponseStatus)

writeSpec :: Test
writeSpec =
  describe "write" do
    it "writes the given status code" do
      status <-
        liftEffect do
          mock <- mockResponse
          write mock 123
          pure $ getResponseStatus mock
      status ?= 123

statusSpec :: Test
statusSpec =
  describe "Status" do
    writeSpec
