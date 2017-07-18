module HTTPure.RequestSpec where

import Prelude (discard, pure, show, unit, (<>), ($), (<<<))

import Data.StrMap as StrMap
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Headers as Headers
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
      case mock "POST" "" StrMap.empty of
        (Request.Post _ _ _) -> pure unit
        a -> Assertions.fail $ "expected a Post, got " <> show a
    Spec.it "has the correct headers" do
      case mock "POST" "" mockHeader of
        (Request.Post headers _ _) ->
          Headers.lookup headers "X-Test" `Assertions.shouldEqual` "test"
        a -> Assertions.fail $ "expected a Post, got " <> show a
    Spec.it "has the correct path" do
      case mock "POST" "test" StrMap.empty of
        (Request.Post _ "test" _) -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
    Spec.pending "has the correct body"

  Spec.describe "with a PUT" do
    Spec.it "is a Put" do
      case mock "PUT" "" StrMap.empty of
        (Request.Put _ _ _) -> pure unit
        a -> Assertions.fail $ "expected a Put, got " <> show a
    Spec.it "has the correct headers" do
      case mock "PUT" "" mockHeader of
        (Request.Put headers _ _) ->
          Headers.lookup headers "X-Test" `Assertions.shouldEqual` "test"
        a -> Assertions.fail $ "expected a Put, got " <> show a
    Spec.it "has the correct path" do
      case mock "PUT" "test" StrMap.empty of
        (Request.Put _ "test" _) -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
    Spec.pending "has the correct body"

  Spec.describe "with a DELETE" do
    Spec.it "is a Delete" do
      case mock "DELETE" "" StrMap.empty of
        (Request.Delete _ _) -> pure unit
        a -> Assertions.fail $ "expected a Delete, got " <> show a
    Spec.it "has the correct headers" do
      case mock "DELETE" "" mockHeader of
        (Request.Delete headers _) ->
          Headers.lookup headers "X-Test" `Assertions.shouldEqual` "test"
        a -> Assertions.fail $ "expected a Delete, got " <> show a
    Spec.it "has the correct path" do
      case mock "DELETE" "test" StrMap.empty of
        (Request.Delete _ "test") -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a

  Spec.describe "with a GET" do
    Spec.it "is a Get" do
      case mock "GET" "" StrMap.empty of
        (Request.Get _ _) -> pure unit
        a -> Assertions.fail $ "expected a Get, got " <> show a
    Spec.it "has the correct headers" do
      case mock "GET" "" mockHeader of
        (Request.Get headers _) ->
          Headers.lookup headers "X-Test" `Assertions.shouldEqual` "test"
        a -> Assertions.fail $ "expected a Get, got " <> show a
    Spec.it "has the correct path" do
      case mock "GET" "test" StrMap.empty of
        (Request.Get _ "test") -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a

  where
    mock path body =
      Request.fromHTTPRequest <<< SpecHelpers.mockRequest path body
    mockHeader = StrMap.singleton "x-test" "test"

requestSpec :: SpecHelpers.Test
requestSpec = Spec.describe "Request" do
  showSpec
  fromHTTPRequestSpec
