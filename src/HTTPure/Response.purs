module HTTPure.Response
  ( Response
  , ResponseM
  , send
  , response, response'
  , binaryResponse, binaryResponse'
  , emptyResponse, emptyResponse'

  -- 1xx
  , continue, continue'
  , switchingProtocols, switchingProtocols'
  , processing, processing'

  -- 2xx
  , ok, ok'
  , created, created'
  , accepted, accepted'
  , nonAuthoritativeInformation, nonAuthoritativeInformation'
  , noContent, noContent'
  , resetContent, resetContent'
  , partialContent, partialContent'
  , multiStatus, multiStatus'
  , alreadyReported, alreadyReported'
  , iMUsed, iMUsed'

  -- 3xx
  , multipleChoices, multipleChoices'
  , movedPermanently, movedPermanently'
  , found, found'
  , seeOther, seeOther'
  , notModified, notModified'
  , useProxy, useProxy'
  , temporaryRedirect, temporaryRedirect'
  , permanentRedirect, permanentRedirect'

  -- 4xx
  , badRequest, badRequest'
  , unauthorized, unauthorized'
  , paymentRequired, paymentRequired'
  , forbidden, forbidden'
  , notFound, notFound'
  , methodNotAllowed, methodNotAllowed'
  , notAcceptable, notAcceptable'
  , proxyAuthenticationRequired, proxyAuthenticationRequired'
  , requestTimeout, requestTimeout'
  , conflict, conflict'
  , gone, gone'
  , lengthRequired, lengthRequired'
  , preconditionFailed, preconditionFailed'
  , payloadTooLarge, payloadTooLarge'
  , uRITooLong, uRITooLong'
  , unsupportedMediaType, unsupportedMediaType'
  , rangeNotSatisfiable, rangeNotSatisfiable'
  , expectationFailed, expectationFailed'
  , imATeapot, imATeapot'
  , misdirectedRequest, misdirectedRequest'
  , unprocessableEntity, unprocessableEntity'
  , locked, locked'
  , failedDependency, failedDependency'
  , upgradeRequired, upgradeRequired'
  , preconditionRequired, preconditionRequired'
  , tooManyRequests, tooManyRequests'
  , requestHeaderFieldsTooLarge, requestHeaderFieldsTooLarge'
  , unavailableForLegalReasons, unavailableForLegalReasons'

  -- 5xx
  , internalServerError, internalServerError'
  , notImplemented, notImplemented'
  , badGateway, badGateway'
  , serviceUnavailable, serviceUnavailable'
  , gatewayTimeout, gatewayTimeout'
  , hTTPVersionNotSupported, hTTPVersionNotSupported'
  , variantAlsoNegotiates, variantAlsoNegotiates'
  , insufficientStorage, insufficientStorage'
  , loopDetected, loopDetected'
  , notExtended, notExtended'
  , networkAuthenticationRequired, networkAuthenticationRequired'
  ) where

import Prelude

import Effect as Effect
import Effect.Aff as Aff
import Node.Buffer as Buffer
import Node.HTTP as HTTP

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.Status as Status

-- | The `ResponseM` type simply conveniently wraps up an HTTPure monad that
-- | returns a response. This type is the return type of all router/route
-- | methods.
type ResponseM = Aff.Aff Response

-- | A `Response` is a status code, headers, and a body.
type Response =
  { status :: Status.Status
  , headers :: Headers.Headers
  , body :: Body.Body
  }

-- | Given an HTTP `Response` and a HTTPure `Response`, this method will return
-- | a monad encapsulating writing the HTTPure `Response` to the HTTP `Response`
-- | and closing the HTTP `Response`.
send :: HTTP.Response -> Response -> Effect.Effect Unit
send httpresponse { status, headers, body } = do
  Status.write httpresponse $ status
  size <- Body.size body
  Headers.write httpresponse $ headers <> contentLength size
  Body.write httpresponse $ body
  where
    contentLength size = Headers.header "Content-Length" $ show size

-- | For custom response statuses or providing a body for response codes that
-- | don't typically send one.
response :: Status.Status -> String -> ResponseM
response status = response' status Headers.empty

-- | The same as `response` but with headers.
response' :: Status.Status ->
             Headers.Headers ->
             String ->
             ResponseM
response' status headers body =
  pure $ { status, headers, body: Body.StringBody body }

-- | Like `response`, but the response body is binary data.
binaryResponse :: Status.Status -> Buffer.Buffer -> Aff.Aff Response
binaryResponse status = binaryResponse' status Headers.empty

-- | The same as `binaryResponse` but with headers.
binaryResponse' :: Status.Status ->
                   Headers.Headers ->
                   Buffer.Buffer ->
                   Aff.Aff Response
binaryResponse' status headers body
  = pure $ { status, headers, body: Body.BinaryBody body }

-- | The same as `response` but without a body.
emptyResponse :: Status.Status -> ResponseM
emptyResponse status = emptyResponse' status Headers.empty

-- | The same as `emptyResponse` but with headers.
emptyResponse' :: Status.Status -> Headers.Headers -> ResponseM
emptyResponse' status headers = response' status headers ""

---------
-- 1xx --
---------

-- | 100
continue :: ResponseM
continue = continue' Headers.empty

-- | 100 with headers
continue' :: Headers.Headers -> ResponseM
continue' = emptyResponse' Status.continue

-- | 101
switchingProtocols :: ResponseM
switchingProtocols = switchingProtocols' Headers.empty

-- | 101 with headers
switchingProtocols' :: Headers.Headers -> ResponseM
switchingProtocols' = emptyResponse' Status.switchingProtocols

-- | 102
processing :: ResponseM
processing = processing' Headers.empty

-- | 102 with headers
processing' :: Headers.Headers -> ResponseM
processing' = emptyResponse' Status.processing

---------
-- 2xx --
---------

-- | 200
ok :: String -> ResponseM
ok = ok' Headers.empty

-- | 200 with headers
ok' :: Headers.Headers -> String -> ResponseM
ok' = response' Status.ok

-- | 201
created :: ResponseM
created = created' Headers.empty

-- | 201 with headers
created' :: Headers.Headers -> ResponseM
created' = emptyResponse' Status.created

-- | 202
accepted :: ResponseM
accepted = accepted' Headers.empty

-- | 202 with headers
accepted' :: Headers.Headers -> ResponseM
accepted' = emptyResponse' Status.accepted

-- | 203
nonAuthoritativeInformation :: String -> ResponseM
nonAuthoritativeInformation = nonAuthoritativeInformation' Headers.empty

-- | 203 with headers
nonAuthoritativeInformation' :: Headers.Headers ->
                                String ->
                                ResponseM
nonAuthoritativeInformation' = response' Status.nonAuthoritativeInformation

-- | 204
noContent :: ResponseM
noContent = noContent' Headers.empty

-- | 204 with headers
noContent' :: Headers.Headers -> ResponseM
noContent' = emptyResponse' Status.noContent

-- | 205
resetContent :: ResponseM
resetContent = resetContent' Headers.empty

-- | 205 with headers
resetContent' :: Headers.Headers -> ResponseM
resetContent' = emptyResponse' Status.resetContent

-- | 206
partialContent :: String -> ResponseM
partialContent = partialContent' Headers.empty

-- | 206 with headers
partialContent' :: Headers.Headers -> String -> ResponseM
partialContent' = response' Status.partialContent

-- | 207
multiStatus :: String -> ResponseM
multiStatus = multiStatus' Headers.empty

-- | 207 with headers
multiStatus' :: Headers.Headers -> String -> ResponseM
multiStatus' = response' Status.multiStatus

-- | 208
alreadyReported :: ResponseM
alreadyReported = alreadyReported' Headers.empty

-- | 208 with headers
alreadyReported' :: Headers.Headers -> ResponseM
alreadyReported' = emptyResponse' Status.alreadyReported

-- | 226
iMUsed :: String -> ResponseM
iMUsed = iMUsed' Headers.empty

-- | 226 with headers
iMUsed' :: Headers.Headers -> String -> ResponseM
iMUsed' = response' Status.iMUsed

---------
-- 3xx --
---------

-- | 300
multipleChoices :: String -> ResponseM
multipleChoices = multipleChoices' Headers.empty

-- | 300 with headers
multipleChoices' :: Headers.Headers -> String -> ResponseM
multipleChoices' = response' Status.multipleChoices

-- | 301
movedPermanently :: String -> ResponseM
movedPermanently = movedPermanently' Headers.empty

-- | 301 with headers
movedPermanently' :: Headers.Headers -> String -> ResponseM
movedPermanently' = response' Status.movedPermanently

-- | 302
found :: String -> ResponseM
found = found' Headers.empty

-- | 302 with headers
found' :: Headers.Headers -> String -> ResponseM
found' = response' Status.found

-- | 303
seeOther :: String -> ResponseM
seeOther = seeOther' Headers.empty

-- | 303 with headers
seeOther' :: Headers.Headers -> String -> ResponseM
seeOther' = response' Status.seeOther

-- | 304
notModified :: ResponseM
notModified = notModified' Headers.empty

-- | 304 with headers
notModified' :: Headers.Headers -> ResponseM
notModified' = emptyResponse' Status.notModified

-- | 305
useProxy :: String -> ResponseM
useProxy = useProxy' Headers.empty

-- | 305 with headers
useProxy' :: Headers.Headers -> String -> ResponseM
useProxy' = response' Status.useProxy

-- | 307
temporaryRedirect :: String -> ResponseM
temporaryRedirect = temporaryRedirect' Headers.empty

-- | 307 with headers
temporaryRedirect' :: Headers.Headers -> String -> ResponseM
temporaryRedirect' = response' Status.temporaryRedirect

-- | 308
permanentRedirect :: String -> ResponseM
permanentRedirect = permanentRedirect' Headers.empty

-- | 308 with headers
permanentRedirect' :: Headers.Headers -> String -> ResponseM
permanentRedirect' = response' Status.permanentRedirect


---------
-- 4xx --
---------

-- | 400
badRequest :: String -> ResponseM
badRequest = badRequest' Headers.empty

-- | 400 with headers
badRequest' :: Headers.Headers -> String -> ResponseM
badRequest' = response' Status.badRequest

-- | 401
unauthorized :: ResponseM
unauthorized = unauthorized' Headers.empty

-- | 401 with headers
unauthorized' :: Headers.Headers -> ResponseM
unauthorized' = emptyResponse' Status.unauthorized

-- | 402
paymentRequired :: ResponseM
paymentRequired = paymentRequired' Headers.empty

-- | 402 with headers
paymentRequired' :: Headers.Headers -> ResponseM
paymentRequired' = emptyResponse' Status.paymentRequired

-- | 403
forbidden :: ResponseM
forbidden = forbidden' Headers.empty

-- | 403 with headers
forbidden' :: Headers.Headers -> ResponseM
forbidden' = emptyResponse' Status.forbidden

-- | 404
notFound :: ResponseM
notFound = notFound' Headers.empty

-- | 404 with headers
notFound' :: Headers.Headers -> ResponseM
notFound' = emptyResponse' Status.notFound

-- | 405
methodNotAllowed :: ResponseM
methodNotAllowed = methodNotAllowed' Headers.empty

-- | 405 with headers
methodNotAllowed' :: Headers.Headers -> ResponseM
methodNotAllowed' = emptyResponse' Status.methodNotAllowed

-- | 406
notAcceptable :: ResponseM
notAcceptable = notAcceptable' Headers.empty

-- | 406 with headers
notAcceptable' :: Headers.Headers -> ResponseM
notAcceptable' = emptyResponse' Status.notAcceptable

-- | 407
proxyAuthenticationRequired :: ResponseM
proxyAuthenticationRequired = proxyAuthenticationRequired' Headers.empty

-- | 407 with headers
proxyAuthenticationRequired' :: Headers.Headers -> ResponseM
proxyAuthenticationRequired' = emptyResponse' Status.proxyAuthenticationRequired

-- | 408
requestTimeout :: ResponseM
requestTimeout = requestTimeout' Headers.empty

-- | 408 with headers
requestTimeout' :: Headers.Headers -> ResponseM
requestTimeout' = emptyResponse' Status.requestTimeout

-- | 409
conflict :: String -> ResponseM
conflict = conflict' Headers.empty

-- | 409 with headers
conflict' :: Headers.Headers -> String -> ResponseM
conflict' = response' Status.conflict

-- | 410
gone :: ResponseM
gone = gone' Headers.empty

-- | 410 with headers
gone' :: Headers.Headers -> ResponseM
gone' = emptyResponse' Status.gone

-- | 411
lengthRequired :: ResponseM
lengthRequired = lengthRequired' Headers.empty

-- | 411 with headers
lengthRequired' :: Headers.Headers -> ResponseM
lengthRequired' = emptyResponse' Status.lengthRequired

-- | 412
preconditionFailed :: ResponseM
preconditionFailed = preconditionFailed' Headers.empty

-- | 412 with headers
preconditionFailed' :: Headers.Headers -> ResponseM
preconditionFailed' = emptyResponse' Status.preconditionFailed

-- | 413
payloadTooLarge :: ResponseM
payloadTooLarge = payloadTooLarge' Headers.empty

-- | 413 with headers
payloadTooLarge' :: Headers.Headers -> ResponseM
payloadTooLarge' = emptyResponse' Status.payloadTooLarge

-- | 414
uRITooLong :: ResponseM
uRITooLong = uRITooLong' Headers.empty

-- | 414 with headers
uRITooLong' :: Headers.Headers -> ResponseM
uRITooLong' = emptyResponse' Status.uRITooLong

-- | 415
unsupportedMediaType :: ResponseM
unsupportedMediaType = unsupportedMediaType' Headers.empty

-- | 415 with headers
unsupportedMediaType' :: Headers.Headers -> ResponseM
unsupportedMediaType' = emptyResponse' Status.unsupportedMediaType

-- | 416
rangeNotSatisfiable :: ResponseM
rangeNotSatisfiable = rangeNotSatisfiable' Headers.empty

-- | 416 with headers
rangeNotSatisfiable' :: Headers.Headers -> ResponseM
rangeNotSatisfiable' = emptyResponse' Status.rangeNotSatisfiable

-- | 417
expectationFailed :: ResponseM
expectationFailed = expectationFailed' Headers.empty

-- | 417 with headers
expectationFailed' :: Headers.Headers -> ResponseM
expectationFailed' = emptyResponse' Status.expectationFailed

-- | 418
imATeapot :: ResponseM
imATeapot = imATeapot' Headers.empty

-- | 418 with headers
imATeapot' :: Headers.Headers -> ResponseM
imATeapot' = emptyResponse' Status.imATeapot

-- | 421
misdirectedRequest :: ResponseM
misdirectedRequest = misdirectedRequest' Headers.empty

-- | 421 with headers
misdirectedRequest' :: Headers.Headers -> ResponseM
misdirectedRequest' = emptyResponse' Status.misdirectedRequest

-- | 422
unprocessableEntity :: ResponseM
unprocessableEntity = unprocessableEntity' Headers.empty

-- | 422 with headers
unprocessableEntity' :: Headers.Headers -> ResponseM
unprocessableEntity' = emptyResponse' Status.unprocessableEntity

-- | 423
locked :: ResponseM
locked = locked' Headers.empty

-- | 423 with headers
locked' :: Headers.Headers -> ResponseM
locked' = emptyResponse' Status.locked

-- | 424
failedDependency :: ResponseM
failedDependency = failedDependency' Headers.empty

-- | 424 with headers
failedDependency' :: Headers.Headers -> ResponseM
failedDependency' = emptyResponse' Status.failedDependency

-- | 426
upgradeRequired :: ResponseM
upgradeRequired = upgradeRequired' Headers.empty

-- | 426 with headers
upgradeRequired' :: Headers.Headers -> ResponseM
upgradeRequired' = emptyResponse' Status.upgradeRequired

-- | 428
preconditionRequired :: ResponseM
preconditionRequired = preconditionRequired' Headers.empty

-- | 428 with headers
preconditionRequired' :: Headers.Headers -> ResponseM
preconditionRequired' = emptyResponse' Status.preconditionRequired

-- | 429
tooManyRequests :: ResponseM
tooManyRequests = tooManyRequests' Headers.empty

-- | 429 with headers
tooManyRequests' :: Headers.Headers -> ResponseM
tooManyRequests' = emptyResponse' Status.tooManyRequests

-- | 431
requestHeaderFieldsTooLarge :: ResponseM
requestHeaderFieldsTooLarge = requestHeaderFieldsTooLarge' Headers.empty

-- | 431 with headers
requestHeaderFieldsTooLarge' :: Headers.Headers -> ResponseM
requestHeaderFieldsTooLarge' = emptyResponse' Status.requestHeaderFieldsTooLarge

-- | 451
unavailableForLegalReasons :: ResponseM
unavailableForLegalReasons = unavailableForLegalReasons' Headers.empty

-- | 451 with headers
unavailableForLegalReasons' :: Headers.Headers -> ResponseM
unavailableForLegalReasons' = emptyResponse' Status.unavailableForLegalReasons

---------
-- 5xx --
---------

-- | 500
internalServerError :: String -> ResponseM
internalServerError = internalServerError' Headers.empty

-- | 500 with headers
internalServerError' :: Headers.Headers -> String -> ResponseM
internalServerError' = response' Status.internalServerError

-- | 501
notImplemented :: ResponseM
notImplemented = notImplemented' Headers.empty

-- | 501 with headers
notImplemented' :: Headers.Headers -> ResponseM
notImplemented' = emptyResponse' Status.notImplemented

-- | 502
badGateway :: ResponseM
badGateway = badGateway' Headers.empty

-- | 502 with headers
badGateway' :: Headers.Headers -> ResponseM
badGateway' = emptyResponse' Status.badGateway

-- | 503
serviceUnavailable :: ResponseM
serviceUnavailable = serviceUnavailable' Headers.empty

-- | 503 with headers
serviceUnavailable' :: Headers.Headers -> ResponseM
serviceUnavailable' = emptyResponse' Status.serviceUnavailable

-- | 504
gatewayTimeout :: ResponseM
gatewayTimeout = gatewayTimeout' Headers.empty

-- | 504 with headers
gatewayTimeout' :: Headers.Headers -> ResponseM
gatewayTimeout' = emptyResponse' Status.gatewayTimeout

-- | 505
hTTPVersionNotSupported :: ResponseM
hTTPVersionNotSupported = hTTPVersionNotSupported' Headers.empty

-- | 505 with headers
hTTPVersionNotSupported' :: Headers.Headers -> ResponseM
hTTPVersionNotSupported' = emptyResponse' Status.hTTPVersionNotSupported

-- | 506
variantAlsoNegotiates :: ResponseM
variantAlsoNegotiates = variantAlsoNegotiates' Headers.empty

-- | 506 with headers
variantAlsoNegotiates' :: Headers.Headers -> ResponseM
variantAlsoNegotiates' = emptyResponse' Status.variantAlsoNegotiates

-- | 507
insufficientStorage :: ResponseM
insufficientStorage = insufficientStorage' Headers.empty

-- | 507 with headers
insufficientStorage' :: Headers.Headers -> ResponseM
insufficientStorage' = emptyResponse' Status.insufficientStorage

-- | 508
loopDetected :: ResponseM
loopDetected = loopDetected' Headers.empty

-- | 508 with headers
loopDetected' :: Headers.Headers -> ResponseM
loopDetected' = emptyResponse' Status.loopDetected

-- | 510
notExtended :: ResponseM
notExtended = notExtended' Headers.empty

-- | 510 with headers
notExtended' :: Headers.Headers -> ResponseM
notExtended' = emptyResponse' Status.notExtended

-- | 511
networkAuthenticationRequired :: ResponseM
networkAuthenticationRequired = networkAuthenticationRequired' Headers.empty

-- | 511 with headers
networkAuthenticationRequired' :: Headers.Headers -> ResponseM
networkAuthenticationRequired' =
  emptyResponse' Status.networkAuthenticationRequired
