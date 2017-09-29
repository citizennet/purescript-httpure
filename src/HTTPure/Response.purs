module HTTPure.Response
  ( Response
  , ResponseM
  , send
  , response, response'
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

import Control.Monad.Eff as Eff
import Control.Monad.Aff as Aff
import Node.HTTP as HTTP

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.HTTPureEffects as HTTPureEffects
import HTTPure.Status as Status

-- | The `ResponseM` type simply conveniently wraps up an HTTPure monad that
-- | returns a response. This type is the return type of all router/route
-- | methods.
type ResponseM e = Aff.Aff (HTTPureEffects.HTTPureEffects e) Response

-- | A `Response` is a status code, headers, and a body.
type Response =
  { status :: Status.Status
  , headers :: Headers.Headers
  , body :: Body.Body
  }

-- | Given an HTTP `Response` and a HTTPure `Response`, this method will return
-- | a monad encapsulating writing the HTTPure `Response` to the HTTP `Response`
-- | and closing the HTTP `Response`.
send :: forall e.
        HTTP.Response ->
        Response ->
        Eff.Eff (HTTPureEffects.HTTPureEffects e) Unit
send httpresponse { status, headers, body } = do
  Status.write httpresponse $ status
  Headers.write httpresponse $ headers
  Body.write httpresponse $ body

-- | For custom response statuses or providing a body for response codes that
-- | don't typically send one.
response :: forall e. Status.Status -> Body.Body -> ResponseM e
response status = response' status Headers.empty

-- | The same as `response` but with headers.
response' :: forall e.
             Status.Status ->
             Headers.Headers ->
             Body.Body ->
             ResponseM e
response' status headers body = pure $ { status, headers, body }

-- | The same as `response` but without a body.
emptyResponse :: forall e. Status.Status -> ResponseM e
emptyResponse status = emptyResponse' status Headers.empty

-- | The same as `emptyResponse` but with headers.
emptyResponse' :: forall e. Status.Status -> Headers.Headers -> ResponseM e
emptyResponse' status headers = response' status headers ""

---------
-- 1xx --
---------

-- | 100
continue :: forall e. ResponseM e
continue = continue' Headers.empty

-- | 100 with headers
continue' :: forall e. Headers.Headers -> ResponseM e
continue' = emptyResponse' Status.continue

-- | 101
switchingProtocols :: forall e. ResponseM e
switchingProtocols = switchingProtocols' Headers.empty

-- | 101 with headers
switchingProtocols' :: forall e. Headers.Headers -> ResponseM e
switchingProtocols' = emptyResponse' Status.switchingProtocols

-- | 102
processing :: forall e. ResponseM e
processing = processing' Headers.empty

-- | 102 with headers
processing' :: forall e. Headers.Headers -> ResponseM e
processing' = emptyResponse' Status.processing

---------
-- 2xx --
---------

-- | 200
ok :: forall e. Body.Body -> ResponseM e
ok = ok' Headers.empty

-- | 200 with headers
ok' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
ok' = response' Status.ok

-- | 201
created :: forall e. ResponseM e
created = created' Headers.empty

-- | 201 with headers
created' :: forall e. Headers.Headers -> ResponseM e
created' = emptyResponse' Status.created

-- | 202
accepted :: forall e. ResponseM e
accepted = accepted' Headers.empty

-- | 202 with headers
accepted' :: forall e. Headers.Headers -> ResponseM e
accepted' = emptyResponse' Status.accepted

-- | 203
nonAuthoritativeInformation :: forall e. Body.Body -> ResponseM e
nonAuthoritativeInformation = nonAuthoritativeInformation' Headers.empty

-- | 203 with headers
nonAuthoritativeInformation' :: forall e.
                                Headers.Headers ->
                                Body.Body ->
                                ResponseM e
nonAuthoritativeInformation' = response' Status.nonAuthoritativeInformation

-- | 204
noContent :: forall e. ResponseM e
noContent = noContent' Headers.empty

-- | 204 with headers
noContent' :: forall e. Headers.Headers -> ResponseM e
noContent' = emptyResponse' Status.noContent

-- | 205
resetContent :: forall e. ResponseM e
resetContent = resetContent' Headers.empty

-- | 205 with headers
resetContent' :: forall e. Headers.Headers -> ResponseM e
resetContent' = emptyResponse' Status.resetContent

-- | 206
partialContent :: forall e. Body.Body -> ResponseM e
partialContent = partialContent' Headers.empty

-- | 206 with headers
partialContent' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
partialContent' = response' Status.partialContent

-- | 207
multiStatus :: forall e. Body.Body -> ResponseM e
multiStatus = multiStatus' Headers.empty

-- | 207 with headers
multiStatus' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
multiStatus' = response' Status.multiStatus

-- | 208
alreadyReported :: forall e. ResponseM e
alreadyReported = alreadyReported' Headers.empty

-- | 208 with headers
alreadyReported' :: forall e. Headers.Headers -> ResponseM e
alreadyReported' = emptyResponse' Status.alreadyReported

-- | 226
iMUsed :: forall e. Body.Body -> ResponseM e
iMUsed = iMUsed' Headers.empty

-- | 226 with headers
iMUsed' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
iMUsed' = response' Status.iMUsed

---------
-- 3xx --
---------

-- | 300
multipleChoices :: forall e. Body.Body -> ResponseM e
multipleChoices = multipleChoices' Headers.empty

-- | 300 with headers
multipleChoices' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
multipleChoices' = response' Status.multipleChoices

-- | 301
movedPermanently :: forall e. Body.Body -> ResponseM e
movedPermanently = movedPermanently' Headers.empty

-- | 301 with headers
movedPermanently' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
movedPermanently' = response' Status.movedPermanently

-- | 302
found :: forall e. Body.Body -> ResponseM e
found = found' Headers.empty

-- | 302 with headers
found' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
found' = response' Status.found

-- | 303
seeOther :: forall e. Body.Body -> ResponseM e
seeOther = seeOther' Headers.empty

-- | 303 with headers
seeOther' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
seeOther' = response' Status.seeOther

-- | 304
notModified :: forall e. ResponseM e
notModified = notModified' Headers.empty

-- | 304 with headers
notModified' :: forall e. Headers.Headers -> ResponseM e
notModified' = emptyResponse' Status.notModified

-- | 305
useProxy :: forall e. Body.Body -> ResponseM e
useProxy = useProxy' Headers.empty

-- | 305 with headers
useProxy' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
useProxy' = response' Status.useProxy

-- | 307
temporaryRedirect :: forall e. Body.Body -> ResponseM e
temporaryRedirect = temporaryRedirect' Headers.empty

-- | 307 with headers
temporaryRedirect' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
temporaryRedirect' = response' Status.temporaryRedirect

-- | 308
permanentRedirect :: forall e. Body.Body -> ResponseM e
permanentRedirect = permanentRedirect' Headers.empty

-- | 308 with headers
permanentRedirect' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
permanentRedirect' = response' Status.permanentRedirect


---------
-- 4xx --
---------

-- | 400
badRequest :: forall e. Body.Body -> ResponseM e
badRequest = badRequest' Headers.empty

-- | 400 with headers
badRequest' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
badRequest' = response' Status.badRequest

-- | 401
unauthorized :: forall e. ResponseM e
unauthorized = unauthorized' Headers.empty

-- | 401 with headers
unauthorized' :: forall e. Headers.Headers -> ResponseM e
unauthorized' = emptyResponse' Status.unauthorized

-- | 402
paymentRequired :: forall e. ResponseM e
paymentRequired = paymentRequired' Headers.empty

-- | 402 with headers
paymentRequired' :: forall e. Headers.Headers -> ResponseM e
paymentRequired' = emptyResponse' Status.paymentRequired

-- | 403
forbidden :: forall e. ResponseM e
forbidden = forbidden' Headers.empty

-- | 403 with headers
forbidden' :: forall e. Headers.Headers -> ResponseM e
forbidden' = emptyResponse' Status.forbidden

-- | 404
notFound :: forall e. ResponseM e
notFound = notFound' Headers.empty

-- | 404 with headers
notFound' :: forall e. Headers.Headers -> ResponseM e
notFound' = emptyResponse' Status.notFound

-- | 405
methodNotAllowed :: forall e. ResponseM e
methodNotAllowed = methodNotAllowed' Headers.empty

-- | 405 with headers
methodNotAllowed' :: forall e. Headers.Headers -> ResponseM e
methodNotAllowed' = emptyResponse' Status.methodNotAllowed

-- | 406
notAcceptable :: forall e. ResponseM e
notAcceptable = notAcceptable' Headers.empty

-- | 406 with headers
notAcceptable' :: forall e. Headers.Headers -> ResponseM e
notAcceptable' = emptyResponse' Status.notAcceptable

-- | 407
proxyAuthenticationRequired :: forall e. ResponseM e
proxyAuthenticationRequired = proxyAuthenticationRequired' Headers.empty

-- | 407 with headers
proxyAuthenticationRequired' :: forall e. Headers.Headers -> ResponseM e
proxyAuthenticationRequired' = emptyResponse' Status.proxyAuthenticationRequired

-- | 408
requestTimeout :: forall e. ResponseM e
requestTimeout = requestTimeout' Headers.empty

-- | 408 with headers
requestTimeout' :: forall e. Headers.Headers -> ResponseM e
requestTimeout' = emptyResponse' Status.requestTimeout

-- | 409
conflict :: forall e. Body.Body -> ResponseM e
conflict = conflict' Headers.empty

-- | 409 with headers
conflict' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
conflict' = response' Status.conflict

-- | 410
gone :: forall e. ResponseM e
gone = gone' Headers.empty

-- | 410 with headers
gone' :: forall e. Headers.Headers -> ResponseM e
gone' = emptyResponse' Status.gone

-- | 411
lengthRequired :: forall e. ResponseM e
lengthRequired = lengthRequired' Headers.empty

-- | 411 with headers
lengthRequired' :: forall e. Headers.Headers -> ResponseM e
lengthRequired' = emptyResponse' Status.lengthRequired

-- | 412
preconditionFailed :: forall e. ResponseM e
preconditionFailed = preconditionFailed' Headers.empty

-- | 412 with headers
preconditionFailed' :: forall e. Headers.Headers -> ResponseM e
preconditionFailed' = emptyResponse' Status.preconditionFailed

-- | 413
payloadTooLarge :: forall e. ResponseM e
payloadTooLarge = payloadTooLarge' Headers.empty

-- | 413 with headers
payloadTooLarge' :: forall e. Headers.Headers -> ResponseM e
payloadTooLarge' = emptyResponse' Status.payloadTooLarge

-- | 414
uRITooLong :: forall e. ResponseM e
uRITooLong = uRITooLong' Headers.empty

-- | 414 with headers
uRITooLong' :: forall e. Headers.Headers -> ResponseM e
uRITooLong' = emptyResponse' Status.uRITooLong

-- | 415
unsupportedMediaType :: forall e. ResponseM e
unsupportedMediaType = unsupportedMediaType' Headers.empty

-- | 415 with headers
unsupportedMediaType' :: forall e. Headers.Headers -> ResponseM e
unsupportedMediaType' = emptyResponse' Status.unsupportedMediaType

-- | 416
rangeNotSatisfiable :: forall e. ResponseM e
rangeNotSatisfiable = rangeNotSatisfiable' Headers.empty

-- | 416 with headers
rangeNotSatisfiable' :: forall e. Headers.Headers -> ResponseM e
rangeNotSatisfiable' = emptyResponse' Status.rangeNotSatisfiable

-- | 417
expectationFailed :: forall e. ResponseM e
expectationFailed = expectationFailed' Headers.empty

-- | 417 with headers
expectationFailed' :: forall e. Headers.Headers -> ResponseM e
expectationFailed' = emptyResponse' Status.expectationFailed

-- | 418
imATeapot :: forall e. ResponseM e
imATeapot = imATeapot' Headers.empty

-- | 418 with headers
imATeapot' :: forall e. Headers.Headers -> ResponseM e
imATeapot' = emptyResponse' Status.imATeapot

-- | 421
misdirectedRequest :: forall e. ResponseM e
misdirectedRequest = misdirectedRequest' Headers.empty

-- | 421 with headers
misdirectedRequest' :: forall e. Headers.Headers -> ResponseM e
misdirectedRequest' = emptyResponse' Status.misdirectedRequest

-- | 422
unprocessableEntity :: forall e. ResponseM e
unprocessableEntity = unprocessableEntity' Headers.empty

-- | 422 with headers
unprocessableEntity' :: forall e. Headers.Headers -> ResponseM e
unprocessableEntity' = emptyResponse' Status.unprocessableEntity

-- | 423
locked :: forall e. ResponseM e
locked = locked' Headers.empty

-- | 423 with headers
locked' :: forall e. Headers.Headers -> ResponseM e
locked' = emptyResponse' Status.locked

-- | 424
failedDependency :: forall e. ResponseM e
failedDependency = failedDependency' Headers.empty

-- | 424 with headers
failedDependency' :: forall e. Headers.Headers -> ResponseM e
failedDependency' = emptyResponse' Status.failedDependency

-- | 426
upgradeRequired :: forall e. ResponseM e
upgradeRequired = upgradeRequired' Headers.empty

-- | 426 with headers
upgradeRequired' :: forall e. Headers.Headers -> ResponseM e
upgradeRequired' = emptyResponse' Status.upgradeRequired

-- | 428
preconditionRequired :: forall e. ResponseM e
preconditionRequired = preconditionRequired' Headers.empty

-- | 428 with headers
preconditionRequired' :: forall e. Headers.Headers -> ResponseM e
preconditionRequired' = emptyResponse' Status.preconditionRequired

-- | 429
tooManyRequests :: forall e. ResponseM e
tooManyRequests = tooManyRequests' Headers.empty

-- | 429 with headers
tooManyRequests' :: forall e. Headers.Headers -> ResponseM e
tooManyRequests' = emptyResponse' Status.tooManyRequests

-- | 431
requestHeaderFieldsTooLarge :: forall e. ResponseM e
requestHeaderFieldsTooLarge = requestHeaderFieldsTooLarge' Headers.empty

-- | 431 with headers
requestHeaderFieldsTooLarge' :: forall e. Headers.Headers -> ResponseM e
requestHeaderFieldsTooLarge' = emptyResponse' Status.requestHeaderFieldsTooLarge

-- | 451
unavailableForLegalReasons :: forall e. ResponseM e
unavailableForLegalReasons = unavailableForLegalReasons' Headers.empty

-- | 451 with headers
unavailableForLegalReasons' :: forall e. Headers.Headers -> ResponseM e
unavailableForLegalReasons' = emptyResponse' Status.unavailableForLegalReasons

---------
-- 5xx --
---------

-- | 500
internalServerError :: forall e. Body.Body -> ResponseM e
internalServerError = internalServerError' Headers.empty

-- | 500 with headers
internalServerError' :: forall e. Headers.Headers -> Body.Body -> ResponseM e
internalServerError' = response' Status.internalServerError

-- | 501
notImplemented :: forall e. ResponseM e
notImplemented = notImplemented' Headers.empty

-- | 501 with headers
notImplemented' :: forall e. Headers.Headers -> ResponseM e
notImplemented' = emptyResponse' Status.notImplemented

-- | 502
badGateway :: forall e. ResponseM e
badGateway = badGateway' Headers.empty

-- | 502 with headers
badGateway' :: forall e. Headers.Headers -> ResponseM e
badGateway' = emptyResponse' Status.badGateway

-- | 503
serviceUnavailable :: forall e. ResponseM e
serviceUnavailable = serviceUnavailable' Headers.empty

-- | 503 with headers
serviceUnavailable' :: forall e. Headers.Headers -> ResponseM e
serviceUnavailable' = emptyResponse' Status.serviceUnavailable

-- | 504
gatewayTimeout :: forall e. ResponseM e
gatewayTimeout = gatewayTimeout' Headers.empty

-- | 504 with headers
gatewayTimeout' :: forall e. Headers.Headers -> ResponseM e
gatewayTimeout' = emptyResponse' Status.gatewayTimeout

-- | 505
hTTPVersionNotSupported :: forall e. ResponseM e
hTTPVersionNotSupported = hTTPVersionNotSupported' Headers.empty

-- | 505 with headers
hTTPVersionNotSupported' :: forall e. Headers.Headers -> ResponseM e
hTTPVersionNotSupported' = emptyResponse' Status.hTTPVersionNotSupported

-- | 506
variantAlsoNegotiates :: forall e. ResponseM e
variantAlsoNegotiates = variantAlsoNegotiates' Headers.empty

-- | 506 with headers
variantAlsoNegotiates' :: forall e. Headers.Headers -> ResponseM e
variantAlsoNegotiates' = emptyResponse' Status.variantAlsoNegotiates

-- | 507
insufficientStorage :: forall e. ResponseM e
insufficientStorage = insufficientStorage' Headers.empty

-- | 507 with headers
insufficientStorage' :: forall e. Headers.Headers -> ResponseM e
insufficientStorage' = emptyResponse' Status.insufficientStorage

-- | 508
loopDetected :: forall e. ResponseM e
loopDetected = loopDetected' Headers.empty

-- | 508 with headers
loopDetected' :: forall e. Headers.Headers -> ResponseM e
loopDetected' = emptyResponse' Status.loopDetected

-- | 510
notExtended :: forall e. ResponseM e
notExtended = notExtended' Headers.empty

-- | 510 with headers
notExtended' :: forall e. Headers.Headers -> ResponseM e
notExtended' = emptyResponse' Status.notExtended

-- | 511
networkAuthenticationRequired :: forall e. ResponseM e
networkAuthenticationRequired = networkAuthenticationRequired' Headers.empty

-- | 511 with headers
networkAuthenticationRequired' :: forall e. Headers.Headers -> ResponseM e
networkAuthenticationRequired' =
  emptyResponse' Status.networkAuthenticationRequired
