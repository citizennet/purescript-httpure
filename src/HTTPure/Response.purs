module HTTPure.Response
  ( ResponseM
  , Response(..)
  , send
  ) where

import Prelude

import Node.HTTP as HTTP

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.HTTPureM as HTTPureM
import HTTPure.Status as Status

-- | A response is a status and headers, and for some statuses, a body. You can
-- | use the data constructor `Response` to send non-standard status codes.
data Response

  -- Non-standard status codes
  = Response Int Headers.Headers Body.Body

  -- 1xx
  | Continue           Headers.Headers
  | SwitchingProtocols Headers.Headers
  | Processing         Headers.Headers

  -- 2xx
  | OK                          Headers.Headers Body.Body
  | Created                     Headers.Headers
  | Accepted                    Headers.Headers
  | NonAuthoritativeInformation Headers.Headers Body.Body
  | NoContent                   Headers.Headers
  | ResetContent                Headers.Headers
  | PartialContent              Headers.Headers Body.Body
  | MultiStatus                 Headers.Headers Body.Body
  | AlreadyReported             Headers.Headers
  | IMUsed                      Headers.Headers Body.Body

  -- 3xx
  | MultipleChoices   Headers.Headers Body.Body
  | MovedPermanently  Headers.Headers Body.Body
  | Found             Headers.Headers Body.Body
  | SeeOther          Headers.Headers Body.Body
  | NotModified       Headers.Headers
  | UseProxy          Headers.Headers Body.Body
  | TemporaryRedirect Headers.Headers Body.Body
  | PermanentRedirect Headers.Headers Body.Body

  -- 4xx
  | BadRequest                  Headers.Headers Body.Body
  | Unauthorized                Headers.Headers
  | PaymentRequired             Headers.Headers
  | Forbidden                   Headers.Headers
  | NotFound                    Headers.Headers
  | MethodNotAllowed            Headers.Headers
  | NotAcceptable               Headers.Headers
  | ProxyAuthenticationRequired Headers.Headers
  | RequestTimeout              Headers.Headers
  | Conflict                    Headers.Headers Body.Body
  | Gone                        Headers.Headers
  | LengthRequired              Headers.Headers
  | PreconditionFailed          Headers.Headers
  | PayloadTooLarge             Headers.Headers
  | URITooLong                  Headers.Headers
  | UnsupportedMediaType        Headers.Headers
  | RangeNotSatisfiable         Headers.Headers
  | ExpectationFailed           Headers.Headers
  | ImATeapot                   Headers.Headers
  | MisdirectedRequest          Headers.Headers
  | UnprocessableEntity         Headers.Headers
  | Locked                      Headers.Headers
  | FailedDependency            Headers.Headers
  | UpgradeRequired             Headers.Headers
  | PreconditionRequired        Headers.Headers
  | TooManyRequests             Headers.Headers
  | RequestHeaderFieldsTooLarge Headers.Headers
  | UnavailableForLegalReasons  Headers.Headers

  -- 5xx
  | InternalServerError           Headers.Headers Body.Body
  | NotImplemented                Headers.Headers
  | BadGateway                    Headers.Headers
  | ServiceUnavailable            Headers.Headers
  | GatewayTimeout                Headers.Headers
  | HTTPVersionNotSupported       Headers.Headers
  | VariantAlsoNegotiates         Headers.Headers
  | InsufficientStorage           Headers.Headers
  | LoopDetected                  Headers.Headers
  | NotExtended                   Headers.Headers
  | NetworkAuthenticationRequired Headers.Headers

-- | The ResponseM type simply conveniently wraps up an HTTPure monad that
-- | returns a response. This type is the return type of all router/route
-- | methods.
type ResponseM e = HTTPureM.HTTPureM e Response

-- | Get the Status for a Response
status :: Response -> Status.Status
status (Response s _ _)                  = s
status (Continue _)                      = 100
status (SwitchingProtocols _)            = 101
status (Processing _)                    = 102
status (OK _ _)                          = 200
status (Created _)                       = 201
status (Accepted _)                      = 202
status (NonAuthoritativeInformation _ _) = 203
status (NoContent _)                     = 204
status (ResetContent _)                  = 205
status (PartialContent _ _)              = 206
status (MultiStatus _ _)                 = 207
status (AlreadyReported _)               = 208
status (IMUsed _ _)                      = 226
status (MultipleChoices _ _)             = 300
status (MovedPermanently _ _)            = 301
status (Found _ _)                       = 302
status (SeeOther _ _)                    = 303
status (NotModified _)                   = 304
status (UseProxy _ _)                    = 305
status (TemporaryRedirect _ _)           = 307
status (PermanentRedirect _ _)           = 308
status (BadRequest _ _)                  = 400
status (Unauthorized _)                  = 401
status (PaymentRequired _)               = 402
status (Forbidden _)                     = 403
status (NotFound _)                      = 404
status (MethodNotAllowed _)              = 405
status (NotAcceptable _)                 = 406
status (ProxyAuthenticationRequired _)   = 407
status (RequestTimeout _)                = 408
status (Conflict _ _)                    = 409
status (Gone _)                          = 410
status (LengthRequired _)                = 411
status (PreconditionFailed _)            = 412
status (PayloadTooLarge _)               = 413
status (URITooLong _)                    = 414
status (UnsupportedMediaType _)          = 415
status (RangeNotSatisfiable _)           = 416
status (ExpectationFailed _)             = 417
status (ImATeapot _)                     = 418
status (MisdirectedRequest _)            = 421
status (UnprocessableEntity _)           = 422
status (Locked _)                        = 423
status (FailedDependency _)              = 424
status (UpgradeRequired _)               = 426
status (PreconditionRequired _)          = 428
status (TooManyRequests _)               = 429
status (RequestHeaderFieldsTooLarge _)   = 431
status (UnavailableForLegalReasons _)    = 451
status (InternalServerError _ _)         = 500
status (NotImplemented _)                = 501
status (BadGateway _)                    = 502
status (ServiceUnavailable _)            = 503
status (GatewayTimeout _)                = 504
status (HTTPVersionNotSupported _)       = 505
status (VariantAlsoNegotiates _)         = 506
status (InsufficientStorage _)           = 507
status (LoopDetected _)                  = 508
status (NotExtended _)                   = 510
status (NetworkAuthenticationRequired _) = 511

-- | Extract the Headers from a Response
headers :: Response -> Headers.Headers
headers (Response _ h _)                  = h
headers (Continue h)                      = h
headers (SwitchingProtocols h)            = h
headers (Processing h)                    = h
headers (OK h _)                          = h
headers (Created h)                       = h
headers (Accepted h)                      = h
headers (NonAuthoritativeInformation h _) = h
headers (NoContent h)                     = h
headers (ResetContent h)                  = h
headers (PartialContent h _)              = h
headers (MultiStatus h _)                 = h
headers (AlreadyReported h)               = h
headers (IMUsed h _)                      = h
headers (MultipleChoices h _)             = h
headers (MovedPermanently h _)            = h
headers (Found h _)                       = h
headers (SeeOther h _)                    = h
headers (NotModified h)                   = h
headers (UseProxy h _)                    = h
headers (TemporaryRedirect h _)           = h
headers (PermanentRedirect h _)           = h
headers (BadRequest h _)                  = h
headers (Unauthorized h)                  = h
headers (PaymentRequired h)               = h
headers (Forbidden h)                     = h
headers (NotFound h)                      = h
headers (MethodNotAllowed h)              = h
headers (NotAcceptable h)                 = h
headers (ProxyAuthenticationRequired h)   = h
headers (RequestTimeout h)                = h
headers (Conflict h _)                    = h
headers (Gone h)                          = h
headers (LengthRequired h)                = h
headers (PreconditionFailed h)            = h
headers (PayloadTooLarge h)               = h
headers (URITooLong h)                    = h
headers (UnsupportedMediaType h)          = h
headers (RangeNotSatisfiable h)           = h
headers (ExpectationFailed h)             = h
headers (ImATeapot h)                     = h
headers (MisdirectedRequest h)            = h
headers (UnprocessableEntity h)           = h
headers (Locked h)                        = h
headers (FailedDependency h)              = h
headers (UpgradeRequired h)               = h
headers (PreconditionRequired h)          = h
headers (TooManyRequests h)               = h
headers (RequestHeaderFieldsTooLarge h)   = h
headers (UnavailableForLegalReasons h)    = h
headers (InternalServerError h _)         = h
headers (NotImplemented h)                = h
headers (BadGateway h)                    = h
headers (ServiceUnavailable h)            = h
headers (GatewayTimeout h)                = h
headers (HTTPVersionNotSupported h)       = h
headers (VariantAlsoNegotiates h)         = h
headers (InsufficientStorage h)           = h
headers (LoopDetected h)                  = h
headers (NotExtended h)                   = h
headers (NetworkAuthenticationRequired h) = h

-- | Extract the Body from a Response
body :: Response -> Body.Body
body (Response _ _ b)                  = b
body (OK _ b)                          = b
body (NonAuthoritativeInformation _ b) = b
body (PartialContent _ b)              = b
body (MultiStatus _ b)                 = b
body (IMUsed _ b)                      = b
body (MultipleChoices _ b)             = b
body (MovedPermanently  _ b)           = b
body (Found _ b)                       = b
body (SeeOther _ b)                    = b
body (UseProxy _ b)                    = b
body (TemporaryRedirect _ b)           = b
body (PermanentRedirect _ b)           = b
body (BadRequest _ b)                  = b
body (Conflict _ b)                    = b
body (InternalServerError _ b)         = b
body _                                 = ""

-- | Given an HTTP response and a HTTPure response, this method will return a
-- | monad encapsulating writing the HTTPure response to the HTTP response and
-- | closing the HTTP response.
send :: forall e. HTTP.Response -> Response -> HTTPureM.HTTPureM e Unit
send httpresponse response = do
  Status.write  httpresponse $ status  response
  Headers.write httpresponse $ headers response
  Body.write    httpresponse $ body    response
