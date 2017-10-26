# Routing in HTTPure

Routing in HTTPure is designed on the simple principle of allowing PureScript to
do what PureScript does best. When you create an HTTPure server, you pass it a
router function:

```purescript
main = HTTPure.serve 8080 router $ Console.log "Server up"
```

The router function is called for each inbound request to the HTTPure server.
Its signature is:

```purescript
forall e. HTTPure.Request -> HTTPure.ResponseM e
```

So in HTTPure, routing is handled simply by the router being a pure function
which is passed a value that contains all information about the current request,
and which returns a response monad. There's no fancy path parsing and matching
algorithm to learn, and everything is pure--you don't get anything or set
anything, you simply define the return value given the input parameters, like
any other pure function.

This is quite powerful, as all routing can be defined using the same PureScript
pattern matching and guard syntax you use everywhere else. It allows you to
break up your router to sub-routers easily, using whatever router grouping makes
sense for your app. It also leads to some powerful patterns for defining and
using middleware. For more details about defining and using middleware, see the
[Middleware guide](./Middleware.md).

For more details about the response monad, see the [Responses
guide](./Responses.md).

## The Request Record

The `HTTPure.Request` type is the input parameter for the router function. It is
a `Record` type that contains the following fields:

- `method` - A member of `HTTPure.Method`.
- `path` - An `Array` of `String` path segments. A path segment is a nonempty
  string separated by a `"/"`. Empty segments are stripped out when HTTPure
  creates the `HTTPure.Request` record.
- `query` - A `StrMap` of `String` values. Note that if you have any query
  parameters without values (for instance, a URL like `/foo?bar`), then the
  value in the `StrMap` for that query parameter will be the empty `String`
  (`""`).
- `headers` - A `HTTPure.Headers` object. The `HTTPure.Headers` newtype wraps
  the `StrMap String` type and provides some typeclass instances that make more
  sense when working with HTTP headers.
- `body` - A `String` containing the contents of the request body, or an empty
  `String` if none was provided.

Following are some more details on working with specific fields, but remember,
you can combine guards and pattern matching for any or all of these fields
however it makes sense for your use case.

## The Lookup Typeclass

You will find that much of HTTPure routing takes advantage of implementations of
the [HTTPure.Lookup](../src/HTTPure/Lookup.purs) typeclass. This typeclass
defines the function `HTTPure.lookup` (or the infix version `!!`), along with a
few auxiliary helpers, for looking up a field out of an object with some key.
There are three instances defined in HTTPure:

1. `Lookup (Array t) Int t` - In this instance, `HTTPure.lookup` is the same as
   `Array.index`. Because the path is represented as an `Array` of `Strings`,
   this can be used to retrieve the nth path segment by doing something like
   `request.path !! n`.
2. `Lookup (StrMap t) String t` - In this instance, `HTTPure.lookup` is a
   flipped version of `StrMap.lookup`. Because the query is a `StrMap String`,
   this instance can be used to retrieve the value of a query parameter by name,
   by doing something like `request.query !! "someparam"`.
3. `Lookup Headers String String` - This is similar to the example in #2, except
   that it works with the `HTTPure.Headers` newtype, and the key is
   case-insensitive (so `request.headers !! "X-Test" == request.headers !!
   "x-test"`).

There are three infix operators defined on the `HTTPure.Lookup` typeclass that
are extremely useful for routing:

1. `!!` - This is an alias to `HTTPure.lookup` itself, and returns a `Maybe`
   containing some type.
2. `!@` - This is the same as `HTTPure.lookup`, but it returns the actual value
   instead of a `Maybe` containing the value. It only operates on instances of
   `HTTPure.Lookup` where the return type is a `Monoid`, and returns `mempty` if
   `HTTPure.lookup` returns `Nothing`. It's especially useful when routing based
   on specific values in query parameters, path segments, or header fields.
3. `!?` - This returns `true` if the key on the right hand side is in the data
   set on the left hand side. In other words, if `HTTPure.lookup` matches
   something, this is `true`, otherwise, this is `false`.

## Matching HTTP Methods

You can use normal pattern matching to route based on the HTTP method:

```purescript
router { method: HTTPure.Post } = HTTPure.ok "received a post"
router { method: HTTPure.Get } = HTTPure.ok "received a get"
router { method } = HTTPure.ok $ "received a " <> show method
```

To see the list of methods that HTTPure understands, see the
[Method](../src/HTTPure/Method.purs) module. To see an example server that
routes based on the HTTP method, see [the Post
example](./Examples/Post/Main.purs).

## Working With Path Segments

Generally, there are two use cases for working with path segments: routing on
them, and using them as variables. When routing on path segments, you can route
on exact path matches:

```purescript
router { path: [ "exact" ] } = HTTPure.ok "matched /exact"
```

You can also route on partial path matches. It's cleanest to use PureScript
guards for this. For instance:

```purescript
router { path }
  | path !@ 0 == "foo" = HTTPure.ok "matched something starting with /foo"
  | path !@ 1 == "bar" = HTTPure.ok "matched something starting with /*/bar"
```

When using a path segment as a variable, simply extract the path segment using
the `HTTPure.Lookup` typeclass:

```purescript
router { path } = HTTPure.ok $ "Path segment 0: " <> path !@ 0
```

To see an example server that works with path segments, see [the Path Segments
example](./Examples/PathSegments/Main.purs).

## Working With Query Parameters

Working with query parameters is very similar to working with path segments. You
can route based on the _existence_ of a query parameter:

```purescript
router { query }
  | query !? "foo" = HTTPure.ok "matched a request containing the 'foo' param"
```

Or you can route based on the _value_ of a query parameter:

```purescript
router { query }
  | query !@ "foo" == "bar" = HTTPure.ok "matched a request with 'foo=bar'"
```

You can of course also use the value of a query parameter to calculate your
response:

```purescript
router { query } = HTTPure.ok $ "The value of 'foo' is " <> query !@ "foo"
```

To see an example server that works with query parameters, see [the Query
Parameters example](./Examples/QueryParameters/Main.purs).

## Working With Request Headers

Headers are again very similar to working with path segments or query
parameters:

```purescript
router { headers }
  | headers !? "X-Foo" = HTTPure.ok "There is an 'X-Foo' header"
  | headers !@ "X-Foo" == "bar" = HTTPure.ok "The header 'X-Foo' is 'bar'"
  | otherwise = HTTPure.ok $ "The value of 'X-Foo' is " <> headers !@ "x-foo"
```

Note that using the `HTTPure.Lookup` typeclass on headers is case-insensitive.

To see an example server that works with headers, see [the Headers
example](./Examples/Headers/Main.purs).
