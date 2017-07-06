module HTTPure.RequestSpec where

import Prelude (($))

import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.SpecHelpers as SpecHelpers

import HTTPure.Request as Request

getURLSpec :: SpecHelpers.Test
getURLSpec = Spec.describe "getURL" $
  Spec.it "is the URL of the request" $
    Request.getURL req `Assertions.shouldEqual` "/test"
    where
      req = SpecHelpers.mockRequest "/test"

requestSpec :: SpecHelpers.Test
requestSpec = Spec.describe "Request" $
  getURLSpec
