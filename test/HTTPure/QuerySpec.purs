module HTTPure.QuerySpec where

import Prelude

import Data.StrMap as StrMap
import Test.Spec as Spec

import HTTPure.Query as Query

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

readSpec :: SpecHelpers.Test
readSpec = Spec.describe "read" do
  Spec.it "is always an empty StrMap (until the stub is fully implemented)" do
    req <- SpecHelpers.mockRequest "" "" "" []
    Query.read req ?= StrMap.empty

querySpec :: SpecHelpers.Test
querySpec = Spec.describe "Query" do
  readSpec
