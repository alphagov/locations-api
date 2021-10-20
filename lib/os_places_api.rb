module OsPlacesApi
  class ExpiredAccessToken < RuntimeError; end

  class InvalidOsPlacesApiCredentials < RuntimeError; end

  class MissingOsPlacesApiCredentials < RuntimeError; end
end
