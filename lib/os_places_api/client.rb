require "httparty"

module OsPlacesApi
  class Client
    def initialize(token_manager)
      @token_manager = token_manager
    end

    def locations_for_postcode(postcode)
      response = HTTParty.get(
        "https://api.os.uk/search/places/v1/postcode",
        {
          query: { postcode: postcode },
          headers: { "Authorization": "Bearer #{@token_manager.access_token}" },
        },
      )

      raise InvalidPostcodeProvided if response.code == 400
      raise ExpiredAccessToken if response.code == 401

      JSON.parse(response)["results"]
    end
  end
end
