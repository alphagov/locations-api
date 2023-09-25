require "httparty"

module OsPlacesApi
  class Client
    def initialize(token_manager)
      @token_manager = token_manager
    end

    def retrieve_locations_for_postcode(normalised_postcode)
      response = get_api_response(normalised_postcode)
      raise NoResultsForPostcode if response["results"].nil?

      OsPlacesApi::LocationResults.new(response["results"])
    end

  private

    def validate_response_code(response)
      raise InvalidPostcodeProvided if response.code == 400
      raise ExpiredAccessToken if response.code == 401
      raise RequestForbidden if response.code == 403
      raise RequestNotFound if response.code == 404
      raise MethodNotAllowed if response.code == 405
      raise RateLimitExceeded if response.code == 429
      raise InternalServerError if response.code == 500
      raise ServiceUnavailable if response.code == 503
    end

    def get_api_response(postcode)
      response = HTTParty.get(
        "https://api.os.uk/search/places/v1/postcode",
        {
          query: { postcode:, output_srs: "WGS84", "dataset": "DPA,LPI" },
          headers: { "Authorization": "Bearer #{@token_manager.access_token}" },
        },
      )

      validate_response_code(response)

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        raise UnexpectedResponse
      end
    end
  end
end
