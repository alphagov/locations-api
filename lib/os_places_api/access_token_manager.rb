module OsPlacesApi
  class AccessTokenManager
    def initialize
      raise MissingOsPlacesApiCredentials unless ENV["OS_PLACES_API_KEY"] && ENV["OS_PLACES_API_SECRET"]
    end
  end
end
