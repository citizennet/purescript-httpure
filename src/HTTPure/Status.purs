module HTTPure.Status
  ( Status
  , write

  -- 1xx
  , continue
  , switchingProtocols
  , processing

  -- 2xx
  , ok
  , created
  , accepted
  , nonAuthoritativeInformation
  , noContent
  , resetContent
  , partialContent
  , multiStatus
  , alreadyReported
  , iMUsed

  -- 3xx
  , multipleChoices
  , movedPermanently
  , found
  , seeOther
  , notModified
  , useProxy
  , temporaryRedirect
  , permanentRedirect

  -- 4xx
  , badRequest
  , unauthorized
  , paymentRequired
  , forbidden
  , notFound
  , methodNotAllowed
  , notAcceptable
  , proxyAuthenticationRequired
  , requestTimeout
  , conflict
  , gone
  , lengthRequired
  , preconditionFailed
  , payloadTooLarge
  , uRITooLong
  , unsupportedMediaType
  , rangeNotSatisfiable
  , expectationFailed
  , imATeapot
  , misdirectedRequest
  , unprocessableEntity
  , locked
  , failedDependency
  , upgradeRequired
  , preconditionRequired
  , tooManyRequests
  , requestHeaderFieldsTooLarge
  , unavailableForLegalReasons

  -- 5xx
  , internalServerError
  , notImplemented
  , badGateway
  , serviceUnavailable
  , gatewayTimeout
  , hTTPVersionNotSupported
  , variantAlsoNegotiates
  , insufficientStorage
  , loopDetected
  , notExtended
  , networkAuthenticationRequired
  ) where

import Prelude

import Control.Monad.Eff as Eff
import Node.HTTP as HTTP

-- | The `Status` type enumerates all valid HTTP response status codes.
type Status = Int

-- | Write a status to a given HTTP `Response`.
write :: forall e.
         HTTP.Response ->
         Status ->
         Eff.Eff (http :: HTTP.HTTP | e) Unit
write = HTTP.setStatusCode

---------
-- 1xx --
---------

-- | 100
continue :: Status
continue = 100

-- | 101
switchingProtocols :: Status
switchingProtocols = 101

-- | 102
processing :: Status
processing = 102

---------
-- 2xx --
---------

-- | 200
ok :: Status
ok = 200

-- | 201
created :: Status
created = 201

-- | 202
accepted :: Status
accepted = 202

-- | 203
nonAuthoritativeInformation :: Status
nonAuthoritativeInformation = 203

-- | 204
noContent :: Status
noContent = 204

-- | 205
resetContent :: Status
resetContent = 205

-- | 206
partialContent :: Status
partialContent = 206

-- | 207
multiStatus :: Status
multiStatus = 207

-- | 208
alreadyReported :: Status
alreadyReported = 208

-- | 226
iMUsed :: Status
iMUsed = 226

---------
-- 3xx --
---------

-- | 300
multipleChoices :: Status
multipleChoices = 300

-- | 301
movedPermanently :: Status
movedPermanently = 301

-- | 302
found :: Status
found = 302

-- | 303
seeOther :: Status
seeOther = 303

-- | 304
notModified :: Status
notModified = 304

-- | 305
useProxy :: Status
useProxy = 305

-- | 307
temporaryRedirect :: Status
temporaryRedirect = 307

-- | 308
permanentRedirect :: Status
permanentRedirect = 308


---------
-- 4xx --
---------

-- | 400
badRequest :: Status
badRequest = 400

-- | 401
unauthorized :: Status
unauthorized = 401

-- | 402
paymentRequired :: Status
paymentRequired = 402

-- | 403
forbidden :: Status
forbidden = 403

-- | 404
notFound :: Status
notFound = 404

-- | 405
methodNotAllowed :: Status
methodNotAllowed = 405

-- | 406
notAcceptable :: Status
notAcceptable = 406

-- | 407
proxyAuthenticationRequired :: Status
proxyAuthenticationRequired = 407

-- | 408
requestTimeout :: Status
requestTimeout = 408

-- | 409
conflict :: Status
conflict = 409

-- | 410
gone :: Status
gone = 410

-- | 411
lengthRequired :: Status
lengthRequired = 411

-- | 412
preconditionFailed :: Status
preconditionFailed = 412

-- | 413
payloadTooLarge :: Status
payloadTooLarge = 413

-- | 414
uRITooLong :: Status
uRITooLong = 414

-- | 415
unsupportedMediaType :: Status
unsupportedMediaType = 415

-- | 416
rangeNotSatisfiable :: Status
rangeNotSatisfiable = 416

-- | 417
expectationFailed :: Status
expectationFailed = 417

-- | 418
imATeapot :: Status
imATeapot = 418

-- | 421
misdirectedRequest :: Status
misdirectedRequest = 421

-- | 422
unprocessableEntity :: Status
unprocessableEntity = 422

-- | 423
locked :: Status
locked = 423

-- | 424
failedDependency :: Status
failedDependency = 424

-- | 426
upgradeRequired :: Status
upgradeRequired = 426

-- | 428
preconditionRequired :: Status
preconditionRequired = 428

-- | 429
tooManyRequests :: Status
tooManyRequests = 429

-- | 431
requestHeaderFieldsTooLarge :: Status
requestHeaderFieldsTooLarge = 431

-- | 451
unavailableForLegalReasons :: Status
unavailableForLegalReasons = 451

---------
-- 5xx --
---------

-- | 500
internalServerError :: Status
internalServerError = 500

-- | 501
notImplemented :: Status
notImplemented = 501

-- | 502
badGateway :: Status
badGateway = 502

-- | 503
serviceUnavailable :: Status
serviceUnavailable = 503

-- | 504
gatewayTimeout :: Status
gatewayTimeout = 504

-- | 505
hTTPVersionNotSupported :: Status
hTTPVersionNotSupported = 505

-- | 506
variantAlsoNegotiates :: Status
variantAlsoNegotiates = 506

-- | 507
insufficientStorage :: Status
insufficientStorage = 507

-- | 508
loopDetected :: Status
loopDetected = 508

-- | 510
notExtended :: Status
notExtended = 510

-- | 511
networkAuthenticationRequired :: Status
networkAuthenticationRequired = 511
