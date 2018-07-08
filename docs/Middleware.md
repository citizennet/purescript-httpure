# Writing and Using Middleware in HTTPure

Since HTTPure routers are just pure functions, you can write a middleware by
simply creating a function that takes a router and an `HTTPure.Request`, and
returns an `HTTPure.ResponseM`. You can then simply use function composition to
combine middlewares, and pass your router to your composed middleware to
generate the decorated router!

See [the Middleware example](./Examples/Middleware/Main.purs) to see how you can
build, compose, and consume different types of middleware.

## Writing Middleware

A middleware is a function with the signature:

```purescript
(HTTPure.Request -> HTTPure.ResponseM) -> HTTPure.Request -> HTTPure.ResponseM
```

Note that the first argument is just the signature for a router function. So
essentially, your middleware should take a router and return a new router.
That's it! You can do pretty much anything with middlewares. Here are a few
examples of common middleware patterns:

You can write a middleware that wraps all future work in some behavior, like
logging or timing:

```purescript
myMiddleware router request = do
  doSomethingBefore
  response <- router request
  doSomethingAfter
  pure response
```

Or perhaps a middleware that injects something into the response:

```purescript
myMiddleware router request = do
  response <- router request
  HTTPure.response' response.status response.headers $
    response.body <> "\n\nGenerated using my super duper middleware!"
```

You could even write a middleware that handles routing for some specific cases:

```purescript
myMiddleware _ { path: [ "somepath" ] } = HTTPure.ok "Handled by my middleware!"
myMiddleware router request = router request
```

Or even a middleware that conditionally includes another middleware:

```purescript
myMiddleware router = if something then someOtherMiddleware router else router
```

Just make sure your middlewares follow the correct signature, and users will be
able to compose them at will!

Note that because there is nothing fancy happening here, you could always write
higher order functions that don't follow this signature, if it makes sense. For
instance, you could write a function that takes two routers, and selects which
one to use based on some criteria. There is nothing wrong with this, but you
should try to use the middleware signature mentioned above as much as possible
as it will make your middleware easier to consume and compose.

## Consuming Middleware

Consuming middleware easy: simply compose all the middleware you want, and then
pass your router to the composed middleware.  For instance:

```purescript
main = HTTPure.serve port composedRouter $ Console.log "Server is up!"
  where
    composedRouter = middlewareA <<< middlewareB <<< middlewareC $ router
```

Be aware of the ordering of the middleware that you compose--since we used
`<<<`, the middlewares will compose right-to-left. But because middlewares
choose when to apply the router to the request, this is a bit like wrapping the
router in each successive middleware from right to left. So when the router
executes on a request, those middlewares will actually _execute_
left-to-right--or from the outermost wrapper inwards.

In other words, say you have the following HTTPure server:

```purescript
middleware letter router request = do
  EffectClass.liftEffect $ Console.log $ "Starting Middleware " <> letter
  response <- router request
  EffectClass.liftEffect $ Console.log $ "Ending Middleware " <> letter
  pure response

main = HTTPure.serve port composedRouter $ Console.log "Server is up!"
  where
    composedRouter = middleware "A" <<< middleware "B" $ router
```

When this HTTPure server receives a request, the logs will include:

```
Starting Middleware A
Starting Middleware B
...
Ending Middleware B
Ending Middleware A
```
