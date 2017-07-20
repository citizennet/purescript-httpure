module HTTPure.RequestSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Headers as Headers
import HTTPure.Request as Request

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

showSpec :: SpecHelpers.Test
showSpec = Spec.describe "show" do
  Spec.describe "with a POST" do
    Spec.it "is the method and the path" do
      show (Request.Post StrMap.empty "test" "") ?= "POST: test"
  Spec.describe "with a PUT" do
    Spec.it "is the method and the path" do
      show (Request.Put StrMap.empty "test" "") ?= "PUT: test"
  Spec.describe "with a DELETE" do
    Spec.it "is the method and the path" do
      show (Request.Delete StrMap.empty "test") ?= "DELETE: test"
  Spec.describe "with a HEAD" do
    Spec.it "is the method and the path" do
      show (Request.Head StrMap.empty "test") ?= "HEAD: test"
  Spec.describe "with a CONNECT" do
    Spec.it "is the method and the path" do
      show (Request.Connect StrMap.empty "test" "") ?= "CONNECT: test"
  Spec.describe "with a OPTIONS" do
    Spec.it "is the method and the path" do
      show (Request.Options StrMap.empty "test") ?= "OPTIONS: test"
  Spec.describe "with a TRACE" do
    Spec.it "is the method and the path" do
      show (Request.Trace StrMap.empty "test") ?= "TRACE: test"
  Spec.describe "with a PATH" do
    Spec.it "is the method and the path" do
      show (Request.Patch StrMap.empty "test" "") ?= "PATCH: test"
  Spec.describe "with a GET" do
    Spec.it "is the method and the path" do
      show (Request.Get StrMap.empty "test") ?= "GET: test"

fromHTTPRequestSpec :: SpecHelpers.Test
fromHTTPRequestSpec = Spec.describe "fromHTTPRequest" do

  Spec.describe "with a POST" do
    Spec.it "is a Post" do
      response <- mock "POST" "" "" StrMap.empty
      case response of
        (Request.Post _ _ _) -> pure unit
        a -> Assertions.fail $ "expected a Post, got " <> show a
    Spec.it "has the correct headers" do
      response <- mock "POST" "" "" mockHeader
      case response of
        (Request.Post headers _ _) ->
          Headers.lookup headers "X-Test" ?= "test"
        a -> Assertions.fail $ "expected a Post, got " <> show a
    Spec.it "has the correct path" do
      response <- mock "POST" "test" "" StrMap.empty
      case response of
        (Request.Post _ "test" _) -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
    Spec.it "has the correct body" do
      response <- mock "POST" "" "test" StrMap.empty
      case response of
        (Request.Post _ _ "test") -> pure unit
        (Request.Post _ _ body) ->
          Assertions.fail $ "expected the body 'test', got " <> body
        a -> Assertions.fail $ "expected a post, got " <> show a

  Spec.describe "with a PUT" do
    Spec.it "is a Put" do
      response <- mock "PUT" "" "" StrMap.empty
      case response of
        (Request.Put _ _ _) -> pure unit
        a -> Assertions.fail $ "expected a Put, got " <> show a
    Spec.it "has the correct headers" do
      response <- mock "PUT" "" "" mockHeader
      case response of
        (Request.Put headers _ _) ->
          Headers.lookup headers "X-Test" ?= "test"
        a -> Assertions.fail $ "expected a Put, got " <> show a
    Spec.it "has the correct path" do
      response <- mock "PUT" "test" "" StrMap.empty
      case response of
        (Request.Put _ "test" _) -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
    Spec.it "has the correct body" do
      response <- mock "PUT" "" "test" StrMap.empty
      case response of
        (Request.Put _ _ "test") -> pure unit
        (Request.Put _ _ body) ->
          Assertions.fail $ "expected the body 'test', got " <> body
        a -> Assertions.fail $ "expected a put, got " <> show a

  Spec.describe "with a DELETE" do
    Spec.it "is a Delete" do
      response <- mock "DELETE" "" "" StrMap.empty
      case response of
        (Request.Delete _ _) -> pure unit
        a -> Assertions.fail $ "expected a Delete, got " <> show a
    Spec.it "has the correct headers" do
      response <- mock "DELETE" "" "" mockHeader
      case response of
        (Request.Delete headers _) ->
          Headers.lookup headers "X-Test" ?= "test"
        a -> Assertions.fail $ "expected a Delete, got " <> show a
    Spec.it "has the correct path" do
      response <- mock "DELETE" "test" "" StrMap.empty
      case response of
        (Request.Delete _ "test") -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a

  Spec.describe "with a HEAD" do
    Spec.it "is a Head" do
      response <- mock "HEAD" "" "" StrMap.empty
      case response of
        (Request.Head _ _) -> pure unit
        a -> Assertions.fail $ "expected a Head, got " <> show a
    Spec.it "has the correct headers" do
      response <- mock "HEAD" "" "" mockHeader
      case response of
        (Request.Head headers _) ->
          Headers.lookup headers "X-Test" ?= "test"
        a -> Assertions.fail $ "expected a Head, got " <> show a
    Spec.it "has the correct path" do
      response <- mock "HEAD" "test" "" StrMap.empty
      case response of
        (Request.Head _ "test") -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a

  Spec.describe "with a CONNECT" do
    Spec.it "is a Connect" do
      response <- mock "CONNECT" "" "" StrMap.empty
      case response of
        (Request.Connect _ _ _) -> pure unit
        a -> Assertions.fail $ "expected a Connect, got " <> show a
    Spec.it "has the correct headers" do
      response <- mock "CONNECT" "" "" mockHeader
      case response of
        (Request.Connect headers _ _) ->
          Headers.lookup headers "X-Test" ?= "test"
        a -> Assertions.fail $ "expected a Connect, got " <> show a
    Spec.it "has the correct path" do
      response <- mock "CONNECT" "test" "" StrMap.empty
      case response of
        (Request.Connect _ "test" _) -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
    Spec.it "has the correct body" do
      response <- mock "CONNECT" "" "test" StrMap.empty
      case response of
        (Request.Connect _ _ "test") -> pure unit
        (Request.Connect _ _ body) ->
          Assertions.fail $ "expected the body 'test', got " <> body
        a -> Assertions.fail $ "expected a connect, got " <> show a

  Spec.describe "with a OPTIONS" do
    Spec.it "is a Options" do
      response <- mock "OPTIONS" "" "" StrMap.empty
      case response of
        (Request.Options _ _) -> pure unit
        a -> Assertions.fail $ "expected a Options, got " <> show a
    Spec.it "has the correct headers" do
      response <- mock "OPTIONS" "" "" mockHeader
      case response of
        (Request.Options headers _) ->
          Headers.lookup headers "X-Test" ?= "test"
        a -> Assertions.fail $ "expected a Options, got " <> show a
    Spec.it "has the correct path" do
      response <- mock "OPTIONS" "test" "" StrMap.empty
      case response of
        (Request.Options _ "test") -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
  
  Spec.describe "with a TRACE" do
    Spec.it "is a Trace" do
      response <- mock "TRACE" "" "" StrMap.empty
      case response of
        (Request.Trace _ _) -> pure unit
        a -> Assertions.fail $ "expected a Trace, got " <> show a
    Spec.it "has the correct headers" do
      response <- mock "TRACE" "" "" mockHeader
      case response of
        (Request.Trace headers _) ->
          Headers.lookup headers "X-Test" ?= "test"
        a -> Assertions.fail $ "expected a Trace, got " <> show a
    Spec.it "has the correct path" do
      response <- mock "TRACE" "test" "" StrMap.empty
      case response of
        (Request.Trace _ "test") -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a

  Spec.describe "with a PATCH" do
    Spec.it "is a Patch" do
      response <- mock "PATCH" "" "" StrMap.empty
      case response of
        (Request.Patch _ _ _) -> pure unit
        a -> Assertions.fail $ "expected a Patch, got " <> show a
    Spec.it "has the correct headers" do
      response <- mock "PATCH" "" "" mockHeader
      case response of
        (Request.Patch headers _ _) ->
          Headers.lookup headers "X-Test" ?= "test"
        a -> Assertions.fail $ "expected a Patch, got " <> show a
    Spec.it "has the correct path" do
      response <- mock "PATCH" "test" "" StrMap.empty
      case response of
        (Request.Patch _ "test" _) -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a
    Spec.it "has the correct body" do
      response <- mock "PATCH" "" "test" StrMap.empty
      case response of
        (Request.Patch _ _ "test") -> pure unit
        (Request.Patch _ _ body) ->
          Assertions.fail $ "expected the body 'test', got " <> body
        a -> Assertions.fail $ "expected a patch, got " <> show a

  Spec.describe "with a GET" do
    Spec.it "is a Get" do
      response <- mock "GET" "" "" StrMap.empty
      case response of
        (Request.Get _ _) -> pure unit
        a -> Assertions.fail $ "expected a Get, got " <> show a
    Spec.it "has the correct headers" do
      response <- mock "GET" "" "" mockHeader
      case response of
        (Request.Get headers _) ->
          Headers.lookup headers "X-Test" ?= "test"
        a -> Assertions.fail $ "expected a Get, got " <> show a
    Spec.it "has the correct path" do
      response <- mock "GET" "test" "" StrMap.empty
      case response of
        (Request.Get _ "test") -> pure unit
        a -> Assertions.fail $ "expected the path 'test', got " <> show a

  where
    mock method path body headers = do
      let req = SpecHelpers.mockRequest method path body headers
      EffClass.liftEff req >>= Request.fromHTTPRequest
    mockHeader = StrMap.singleton "x-test" "test"

requestSpec :: SpecHelpers.Test
requestSpec = Spec.describe "Request" do
  showSpec
  fromHTTPRequestSpec
