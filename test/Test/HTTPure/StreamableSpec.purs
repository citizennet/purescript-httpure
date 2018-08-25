module Test.HTTPure.StreamableSpec where

import Prelude

import Effect.Class as EffectClass
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Test.Spec as Spec

import HTTPure.Streamable as Streamable

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

toStreamSpec :: TestHelpers.Test
toStreamSpec = Spec.describe "toStream" do
  Spec.describe "String" do
    Spec.it "converts to a stream properly" do
      test <- TestHelpers.streamToString $ Streamable.toStream "test"
      test ?= "test"
  Spec.describe "Buffer" do
    Spec.it "converts to a stream properly" do
      buf <- EffectClass.liftEffect $ Buffer.fromString "test" Encoding.UTF8
      test <- TestHelpers.streamToString $ Streamable.toStream buf
      test ?= "test"

streamableSpec :: TestHelpers.Test
streamableSpec = Spec.describe "Streamable" do
  toStreamSpec
