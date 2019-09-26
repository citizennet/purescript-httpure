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

import Effect.Aff as Aff
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect)
import Effect.Class as EffectClass
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
  , writeBody :: HTTP.Response -> Aff.Aff Unit
  }

-- | Given an HTTP `Response` and a HTTPure `Response`, this method will return
-- | a monad encapsulating writing the HTTPure `Response` to the HTTP `Response`
-- | and closing the HTTP `Response`.
send :: forall m. MonadEffect m => MonadAff m => HTTP.Response -> Response -> m Unit
send httpresponse { status, headers, writeBody } = do
  EffectClass.liftEffect $ Status.write httpresponse status
  EffectClass.liftEffect $ Headers.write httpresponse headers
  liftAff $ writeBody httpresponse

-- | For custom response statuses or providing a body for response codes that
-- | don't typically send one.
response :: forall m b. MonadAff m => Body.Body b => Status.Status -> b -> m Response
response status = response' status Headers.empty

-- | The same as `response` but with headers.
response' :: forall m b. MonadAff m =>
             Body.Body b =>
             Status.Status ->
             Headers.Headers ->
             b ->
             m Response
response' status headers body = EffectClass.liftEffect do
  defaultHeaders <- Body.defaultHeaders body
  pure
    { status
    , headers: defaultHeaders <> headers
    , writeBody: Body.write body
    }

-- | The same as `response` but without a body.
emptyResponse :: forall m. MonadAff m => Status.Status -> m Response
emptyResponse status = emptyResponse' status Headers.empty

-- | The same as `emptyResponse` but with headers.
emptyResponse' :: forall m. MonadAff m => Status.Status -> Headers.Headers -> m Response
emptyResponse' status headers = response' status headers ""

---------
-- 1xx --
---------

-- | 100
continue :: forall m. MonadAff m => m Response
continue = continue' Headers.empty

-- | 100 with headers
continue' :: forall m. MonadAff m => Headers.Headers -> m Response
continue' = emptyResponse' Status.continue

-- | 101
switchingProtocols :: forall m. MonadAff m => m Response
switchingProtocols = switchingProtocols' Headers.empty

-- | 101 with headers
switchingProtocols' :: forall m. MonadAff m => Headers.Headers -> m Response
switchingProtocols' = emptyResponse' Status.switchingProtocols

-- | 102
processing :: forall m. MonadAff m => m Response
processing = processing' Headers.empty

-- | 102 with headers
processing' :: forall m. MonadAff m => Headers.Headers -> m Response
processing' = emptyResponse' Status.processing

---------
-- 2xx --
---------

-- | 200
ok :: forall m b. MonadAff m => Body.Body b => b -> m Response
ok = ok' Headers.empty

-- | 200 with headers
ok' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
ok' = response' Status.ok

-- | 201
created :: forall m. MonadAff m => m Response
created = created' Headers.empty

-- | 201 with headers
created' :: forall m. MonadAff m => Headers.Headers -> m Response
created' = emptyResponse' Status.created

-- | 202
accepted :: forall m. MonadAff m => m Response
accepted = accepted' Headers.empty

-- | 202 with headers
accepted' :: forall m. MonadAff m => Headers.Headers -> m Response
accepted' = emptyResponse' Status.accepted

-- | 203
nonAuthoritativeInformation :: forall m b. MonadAff m => Body.Body b => b -> m Response
nonAuthoritativeInformation = nonAuthoritativeInformation' Headers.empty

-- | 203 with headers
nonAuthoritativeInformation' :: forall m b. MonadAff m =>
                                Body.Body b =>
                                Headers.Headers ->
                                b ->
                                m Response
nonAuthoritativeInformation' = response' Status.nonAuthoritativeInformation

-- | 204
noContent :: forall m. MonadAff m => m Response
noContent = noContent' Headers.empty

-- | 204 with headers
noContent' :: forall m. MonadAff m => Headers.Headers -> m Response
noContent' = emptyResponse' Status.noContent

-- | 205
resetContent :: forall m. MonadAff m => m Response
resetContent = resetContent' Headers.empty

-- | 205 with headers
resetContent' :: forall m. MonadAff m => Headers.Headers -> m Response
resetContent' = emptyResponse' Status.resetContent

-- | 206
partialContent :: forall m b. MonadAff m => Body.Body b => b -> m Response
partialContent = partialContent' Headers.empty

-- | 206 with headers
partialContent' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
partialContent' = response' Status.partialContent

-- | 207
multiStatus :: forall m b. MonadAff m => Body.Body b => b -> m Response
multiStatus = multiStatus' Headers.empty

-- | 207 with headers
multiStatus' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
multiStatus' = response' Status.multiStatus

-- | 208
alreadyReported :: forall m. MonadAff m => m Response
alreadyReported = alreadyReported' Headers.empty

-- | 208 with headers
alreadyReported' :: forall m. MonadAff m => Headers.Headers -> m Response
alreadyReported' = emptyResponse' Status.alreadyReported

-- | 226
iMUsed :: forall m b. MonadAff m => Body.Body b => b -> m Response
iMUsed = iMUsed' Headers.empty

-- | 226 with headers
iMUsed' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
iMUsed' = response' Status.iMUsed

---------
-- 3xx --
---------

-- | 300
multipleChoices :: forall m b. MonadAff m => Body.Body b => b -> m Response
multipleChoices = multipleChoices' Headers.empty

-- | 300 with headers
multipleChoices' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
multipleChoices' = response' Status.multipleChoices

-- | 301
movedPermanently :: forall m b. MonadAff m => Body.Body b => b -> m Response
movedPermanently = movedPermanently' Headers.empty

-- | 301 with headers
movedPermanently' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
movedPermanently' = response' Status.movedPermanently

-- | 302
found :: forall m b. MonadAff m => Body.Body b => b -> m Response
found = found' Headers.empty

-- | 302 with headers
found' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
found' = response' Status.found

-- | 303
seeOther :: forall m b. MonadAff m => Body.Body b => b -> m Response
seeOther = seeOther' Headers.empty

-- | 303 with headers
seeOther' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
seeOther' = response' Status.seeOther

-- | 304
notModified :: forall m. MonadAff m => m Response
notModified = notModified' Headers.empty

-- | 304 with headers
notModified' :: forall m. MonadAff m => Headers.Headers -> m Response
notModified' = emptyResponse' Status.notModified

-- | 305
useProxy :: forall m b. MonadAff m => Body.Body b => b -> m Response
useProxy = useProxy' Headers.empty

-- | 305 with headers
useProxy' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
useProxy' = response' Status.useProxy

-- | 307
temporaryRedirect :: forall m b. MonadAff m => Body.Body b => b -> m Response
temporaryRedirect = temporaryRedirect' Headers.empty

-- | 307 with headers
temporaryRedirect' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
temporaryRedirect' = response' Status.temporaryRedirect

-- | 308
permanentRedirect :: forall m b. MonadAff m => Body.Body b => b -> m Response
permanentRedirect = permanentRedirect' Headers.empty

-- | 308 with headers
permanentRedirect' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
permanentRedirect' = response' Status.permanentRedirect


---------
-- 4xx --
---------

-- | 400
badRequest :: forall m b. MonadAff m => Body.Body b => b -> m Response
badRequest = badRequest' Headers.empty

-- | 400 with headers
badRequest' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
badRequest' = response' Status.badRequest

-- | 401
unauthorized :: forall m. MonadAff m => m Response
unauthorized = unauthorized' Headers.empty

-- | 401 with headers
unauthorized' :: forall m. MonadAff m => Headers.Headers -> m Response
unauthorized' = emptyResponse' Status.unauthorized

-- | 402
paymentRequired :: forall m. MonadAff m => m Response
paymentRequired = paymentRequired' Headers.empty

-- | 402 with headers
paymentRequired' :: forall m. MonadAff m => Headers.Headers -> m Response
paymentRequired' = emptyResponse' Status.paymentRequired

-- | 403
forbidden :: forall m. MonadAff m => m Response
forbidden = forbidden' Headers.empty

-- | 403 with headers
forbidden' :: forall m. MonadAff m => Headers.Headers -> m Response
forbidden' = emptyResponse' Status.forbidden

-- | 404
notFound :: forall m. MonadAff m => m Response
notFound = notFound' Headers.empty

-- | 404 with headers
notFound' :: forall m. MonadAff m => Headers.Headers -> m Response
notFound' = emptyResponse' Status.notFound

-- | 405
methodNotAllowed :: forall m. MonadAff m => m Response
methodNotAllowed = methodNotAllowed' Headers.empty

-- | 405 with headers
methodNotAllowed' :: forall m. MonadAff m => Headers.Headers -> m Response
methodNotAllowed' = emptyResponse' Status.methodNotAllowed

-- | 406
notAcceptable :: forall m. MonadAff m => m Response
notAcceptable = notAcceptable' Headers.empty

-- | 406 with headers
notAcceptable' :: forall m. MonadAff m => Headers.Headers -> m Response
notAcceptable' = emptyResponse' Status.notAcceptable

-- | 407
proxyAuthenticationRequired :: forall m. MonadAff m => m Response
proxyAuthenticationRequired = proxyAuthenticationRequired' Headers.empty

-- | 407 with headers
proxyAuthenticationRequired' :: forall m. MonadAff m => Headers.Headers -> m Response
proxyAuthenticationRequired' = emptyResponse' Status.proxyAuthenticationRequired

-- | 408
requestTimeout :: forall m. MonadAff m => m Response
requestTimeout = requestTimeout' Headers.empty

-- | 408 with headers
requestTimeout' :: forall m. MonadAff m => Headers.Headers -> m Response
requestTimeout' = emptyResponse' Status.requestTimeout

-- | 409
conflict :: forall m b. MonadAff m => Body.Body b => b -> m Response
conflict = conflict' Headers.empty

-- | 409 with headers
conflict' :: forall m b. MonadAff m => Body.Body b => Headers.Headers -> b -> m Response
conflict' = response' Status.conflict

-- | 410
gone :: forall m. MonadAff m => m Response
gone = gone' Headers.empty

-- | 410 with headers
gone' :: forall m. MonadAff m => Headers.Headers -> m Response
gone' = emptyResponse' Status.gone

-- | 411
lengthRequired :: forall m. MonadAff m => m Response
lengthRequired = lengthRequired' Headers.empty

-- | 411 with headers
lengthRequired' :: forall m. MonadAff m => Headers.Headers -> m Response
lengthRequired' = emptyResponse' Status.lengthRequired

-- | 412
preconditionFailed :: forall m. MonadAff m => m Response
preconditionFailed = preconditionFailed' Headers.empty

-- | 412 with headers
preconditionFailed' :: forall m. MonadAff m => Headers.Headers -> m Response
preconditionFailed' = emptyResponse' Status.preconditionFailed

-- | 413
payloadTooLarge :: forall m. MonadAff m => m Response
payloadTooLarge = payloadTooLarge' Headers.empty

-- | 413 with headers
payloadTooLarge' :: forall m. MonadAff m => Headers.Headers -> m Response
payloadTooLarge' = emptyResponse' Status.payloadTooLarge

-- | 414
uRITooLong :: forall m. MonadAff m => m Response
uRITooLong = uRITooLong' Headers.empty

-- | 414 with headers
uRITooLong' :: forall m. MonadAff m => Headers.Headers -> m Response
uRITooLong' = emptyResponse' Status.uRITooLong

-- | 415
unsupportedMediaType :: forall m. MonadAff m => m Response
unsupportedMediaType = unsupportedMediaType' Headers.empty

-- | 415 with headers
unsupportedMediaType' :: forall m. MonadAff m => Headers.Headers -> m Response
unsupportedMediaType' = emptyResponse' Status.unsupportedMediaType

-- | 416
rangeNotSatisfiable :: forall m. MonadAff m => m Response
rangeNotSatisfiable = rangeNotSatisfiable' Headers.empty

-- | 416 with headers
rangeNotSatisfiable' :: forall m. MonadAff m => Headers.Headers -> m Response
rangeNotSatisfiable' = emptyResponse' Status.rangeNotSatisfiable

-- | 417
expectationFailed :: forall m. MonadAff m => m Response
expectationFailed = expectationFailed' Headers.empty

-- | 417 with headers
expectationFailed' :: forall m. MonadAff m => Headers.Headers -> m Response
expectationFailed' = emptyResponse' Status.expectationFailed

-- | 418
imATeapot :: forall m. MonadAff m => m Response
imATeapot = imATeapot' Headers.empty

-- | 418 with headers
imATeapot' :: forall m. MonadAff m => Headers.Headers -> m Response
imATeapot' = emptyResponse' Status.imATeapot

-- | 421
misdirectedRequest :: forall m. MonadAff m => m Response
misdirectedRequest = misdirectedRequest' Headers.empty

-- | 421 with headers
misdirectedRequest' :: forall m. MonadAff m => Headers.Headers -> m Response
misdirectedRequest' = emptyResponse' Status.misdirectedRequest

-- | 422
unprocessableEntity :: forall m. MonadAff m => m Response
unprocessableEntity = unprocessableEntity' Headers.empty

-- | 422 with headers
unprocessableEntity' :: forall m. MonadAff m => Headers.Headers -> m Response
unprocessableEntity' = emptyResponse' Status.unprocessableEntity

-- | 423
locked :: forall m. MonadAff m => m Response
locked = locked' Headers.empty

-- | 423 with headers
locked' :: forall m. MonadAff m => Headers.Headers -> m Response
locked' = emptyResponse' Status.locked

-- | 424
failedDependency :: forall m. MonadAff m => m Response
failedDependency = failedDependency' Headers.empty

-- | 424 with headers
failedDependency' :: forall m. MonadAff m => Headers.Headers -> m Response
failedDependency' = emptyResponse' Status.failedDependency

-- | 426
upgradeRequired :: forall m. MonadAff m => m Response
upgradeRequired = upgradeRequired' Headers.empty

-- | 426 with headers
upgradeRequired' :: forall m. MonadAff m => Headers.Headers -> m Response
upgradeRequired' = emptyResponse' Status.upgradeRequired

-- | 428
preconditionRequired :: forall m. MonadAff m => m Response
preconditionRequired = preconditionRequired' Headers.empty

-- | 428 with headers
preconditionRequired' :: forall m. MonadAff m => Headers.Headers -> m Response
preconditionRequired' = emptyResponse' Status.preconditionRequired

-- | 429
tooManyRequests :: forall m. MonadAff m => m Response
tooManyRequests = tooManyRequests' Headers.empty

-- | 429 with headers
tooManyRequests' :: forall m. MonadAff m => Headers.Headers -> m Response
tooManyRequests' = emptyResponse' Status.tooManyRequests

-- | 431
requestHeaderFieldsTooLarge :: forall m. MonadAff m => m Response
requestHeaderFieldsTooLarge = requestHeaderFieldsTooLarge' Headers.empty

-- | 431 with headers
requestHeaderFieldsTooLarge' :: forall m. MonadAff m => Headers.Headers -> m Response
requestHeaderFieldsTooLarge' = emptyResponse' Status.requestHeaderFieldsTooLarge

-- | 451
unavailableForLegalReasons :: forall m. MonadAff m => m Response
unavailableForLegalReasons = unavailableForLegalReasons' Headers.empty

-- | 451 with headers
unavailableForLegalReasons' :: forall m. MonadAff m => Headers.Headers -> m Response
unavailableForLegalReasons' = emptyResponse' Status.unavailableForLegalReasons

---------
-- 5xx --
---------

-- | 500
internalServerError :: forall m b. MonadAff m => Body.Body b => b -> m Response
internalServerError = internalServerError' Headers.empty

-- | 500 with headers
internalServerError' :: forall m b. MonadAff m =>
                        Body.Body b =>
                        Headers.Headers ->
                        b ->
                        m Response
internalServerError' = response' Status.internalServerError

-- | 501
notImplemented :: forall m. MonadAff m => m Response
notImplemented = notImplemented' Headers.empty

-- | 501 with headers
notImplemented' :: forall m. MonadAff m => Headers.Headers -> m Response
notImplemented' = emptyResponse' Status.notImplemented

-- | 502
badGateway :: forall m. MonadAff m => m Response
badGateway = badGateway' Headers.empty

-- | 502 with headers
badGateway' :: forall m. MonadAff m => Headers.Headers -> m Response
badGateway' = emptyResponse' Status.badGateway

-- | 503
serviceUnavailable :: forall m. MonadAff m => m Response
serviceUnavailable = serviceUnavailable' Headers.empty

-- | 503 with headers
serviceUnavailable' :: forall m. MonadAff m => Headers.Headers -> m Response
serviceUnavailable' = emptyResponse' Status.serviceUnavailable

-- | 504
gatewayTimeout :: forall m. MonadAff m => m Response
gatewayTimeout = gatewayTimeout' Headers.empty

-- | 504 with headers
gatewayTimeout' :: forall m. MonadAff m => Headers.Headers -> m Response
gatewayTimeout' = emptyResponse' Status.gatewayTimeout

-- | 505
hTTPVersionNotSupported :: forall m. MonadAff m => m Response
hTTPVersionNotSupported = hTTPVersionNotSupported' Headers.empty

-- | 505 with headers
hTTPVersionNotSupported' :: forall m. MonadAff m => Headers.Headers -> m Response
hTTPVersionNotSupported' = emptyResponse' Status.hTTPVersionNotSupported

-- | 506
variantAlsoNegotiates :: forall m. MonadAff m => m Response
variantAlsoNegotiates = variantAlsoNegotiates' Headers.empty

-- | 506 with headers
variantAlsoNegotiates' :: forall m. MonadAff m => Headers.Headers -> m Response
variantAlsoNegotiates' = emptyResponse' Status.variantAlsoNegotiates

-- | 507
insufficientStorage :: forall m. MonadAff m => m Response
insufficientStorage = insufficientStorage' Headers.empty

-- | 507 with headers
insufficientStorage' :: forall m. MonadAff m => Headers.Headers -> m Response
insufficientStorage' = emptyResponse' Status.insufficientStorage

-- | 508
loopDetected :: forall m. MonadAff m => m Response
loopDetected = loopDetected' Headers.empty

-- | 508 with headers
loopDetected' :: forall m. MonadAff m => Headers.Headers -> m Response
loopDetected' = emptyResponse' Status.loopDetected

-- | 510
notExtended :: forall m. MonadAff m => m Response
notExtended = notExtended' Headers.empty

-- | 510 with headers
notExtended' :: forall m. MonadAff m => Headers.Headers -> m Response
notExtended' = emptyResponse' Status.notExtended

-- | 511
networkAuthenticationRequired :: forall m. MonadAff m => m Response
networkAuthenticationRequired = networkAuthenticationRequired' Headers.empty

-- | 511 with headers
networkAuthenticationRequired' :: forall m. MonadAff m => Headers.Headers -> m Response
networkAuthenticationRequired' =
  emptyResponse' Status.networkAuthenticationRequired
