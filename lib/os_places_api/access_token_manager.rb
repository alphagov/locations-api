require "httparty"

module OsPlacesApi
  class AccessTokenManager
    def initialize
      raise MissingOsPlacesApiCredentials unless ENV["OS_PLACES_API_KEY"] && ENV["OS_PLACES_API_SECRET"]

      @os_places_api_key = ENV["OS_PLACES_API_KEY"]
      @os_places_api_secret = ENV["OS_PLACES_API_SECRET"]
    end

    def access_token
      response = HTTParty.post(
        "https://api.os.uk/oauth2/token/v1",
        basic_auth: { username: @os_places_api_key, password: @os_places_api_secret },
        body: { grant_type: "client_credentials" },
      )
      raise InvalidOsPlacesApiCredentials if response.code == 401

      JSON.parse(response.body)["access_token"]
    end
  end
end
