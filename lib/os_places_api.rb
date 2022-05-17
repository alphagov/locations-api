module OsPlacesApi
  class ClientError < RuntimeError; end

  class ExpiredAccessToken < ClientError; end

  class InvalidOsPlacesApiCredentials < ClientError; end

  class InvalidPostcodeProvided < ClientError; end

  class InternalServerError < ClientError; end

  class MethodNotAllowed < ClientError; end

  class MissingOsPlacesApiCredentials < ClientError; end

  class RateLimitExceeded < ClientError; end

  class RequestForbidden < ClientError; end

  class RequestNotFound < ClientError; end

  class ServiceUnavailable < ClientError; end

  class UnexpectedResponse < ClientError; end
end
