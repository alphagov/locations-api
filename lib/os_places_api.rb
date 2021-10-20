module OsPlacesApi
  class ExpiredAccessToken < RuntimeError; end

  class InvalidOsPlacesApiCredentials < RuntimeError; end

  class InvalidPostcodeProvided < RuntimeError; end

  class InternalServerError < RuntimeError; end

  class MethodNotAllowed < RuntimeError; end

  class MissingOsPlacesApiCredentials < RuntimeError; end

  class RateLimitExceeded < RuntimeError; end

  class RequestForbidden < RuntimeError; end

  class RequestNotFound < RuntimeError; end

  class ServiceUnavailable < RuntimeError; end

  class UnexpectedResponse < RuntimeError; end
end
