module HTTPure
  ( module HTTPure.Headers
  , module HTTPure.Lookup
  , module HTTPure.Method
  , module HTTPure.Path
  , module HTTPure.Request
  , module HTTPure.Response
  , module HTTPure.Server
  ) where

import HTTPure.Headers (Headers, empty, header, headers)
import HTTPure.Lookup (lookup, (!!))
import HTTPure.Method (Method(..))
import HTTPure.Path (Path)
import HTTPure.Request (Request, fullPath)
import HTTPure.Response
  ( ResponseM
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
  )
import HTTPure.Server (SecureServerM, ServerM, serve, serve')
