module HTTPure.RequestSpec where

import Prelude (discard, pure, show, unit, (<>), ($))

import Data.StrMap as StrMap
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Request as Request

import HTTPure.SpecHelpers as SpecHelpers

showSpec :: SpecHelpers.Test
showSpec = Spec.describe "show" do
  Spec.describe "with a POST" do
    Spec.it "is the method and the path" do
      show (Request.Post none "test" "") `Assertions.shouldEqual` "POST: test"
  Spec.describe "with a PUT" do
    Spec.it "is the method and the path" do
      show (Request.Put none "test" "") `Assertions.shouldEqual` "PUT: test"
  Spec.describe "with a DELETE" do
    Spec.it "is the method and the path" do
      show (Request.Delete none "test") `Assertions.shouldEqual` "DELETE: test"
  Spec.describe "with a GET" do
    Spec.it "is the method and the path" do
      show (Request.Get none "test") `Assertions.shouldEqual` "GET: test"
  where
    none = StrMap.empty

fromHTTPRequestSpec :: SpecHelpers.Test
fromHTTPRequestSpec = Spec.describe "fromHTTPRequest" do

  Spec.describe "with a POST" do
    Spec.it "is a Post" do
      case Request.fromHTTPRequest (SpecHelpers.mockRequest "POST" "") of
        (Request.Post _ _ _) -> pure unit
        a -> Assertions.fail $ "expected a Post, got " <> show a
    Spec.pending "has the correct headers"
    Spec.it "has the correct path" do
      case Request.fromHTTPRequest (SpecHelpers.mockRequest "POST" "test") of
        (Request.Post _ "test" _) -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
    Spec.pending "has the correct body"

  Spec.describe "with a PUT" do
    Spec.it "is a Put" do
      case Request.fromHTTPRequest (SpecHelpers.mockRequest "PUT" "") of
        (Request.Put _ _ _) -> pure unit
        a -> Assertions.fail $ "expected a Put, got " <> show a
    Spec.pending "has the correct headers"
    Spec.it "has the correct path" do
      case Request.fromHTTPRequest (SpecHelpers.mockRequest "PUT" "test") of
        (Request.Put _ "test" _) -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
    Spec.pending "has the correct body"

  Spec.describe "with a DELETE" do
    Spec.it "is a Delete" do
      case Request.fromHTTPRequest (SpecHelpers.mockRequest "DELETE" "") of
        (Request.Delete _ _) -> pure unit
        a -> Assertions.fail $ "expected a Delete, got " <> show a
    Spec.pending "has the correct headers"
    Spec.it "has the correct path" do
      case Request.fromHTTPRequest (SpecHelpers.mockRequest "DELETE" "test") of
        (Request.Delete _ "test") -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a

  Spec.describe "with a GET" do
    Spec.it "is a Get" do
      case Request.fromHTTPRequest (SpecHelpers.mockRequest "GET" "") of
        (Request.Get _ _) -> pure unit
        a -> Assertions.fail $ "expected a Get, got " <> show a
    Spec.it "has the correct path" do
      case Request.fromHTTPRequest (SpecHelpers.mockRequest "GET" "test") of
        (Request.Get _ "test") -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
    Spec.pending "has the correct headers"

requestSpec :: SpecHelpers.Test
requestSpec = Spec.describe "Request" do
  showSpec
  fromHTTPRequestSpec
