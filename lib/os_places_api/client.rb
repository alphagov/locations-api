require "httparty"

module OsPlacesApi
  class Client
    def initialize(token_manager)
      @token_manager = token_manager
    end

    def locations_for_postcode(postcode, update: false)
      if (record = Postcode.find_by(postcode: postcode)) && !update
        return build_locations(record["results"])
      end

      response = HTTParty.get(
        "https://api.os.uk/search/places/v1/postcode",
        {
          query: { postcode: postcode, output_srs: "WGS84" },
          headers: { "Authorization": "Bearer #{@token_manager.access_token}" },
        },
      )

      validate_response_code(response)

      begin
        json = JSON.parse(response.body)
        raise UnexpectedResponse if json["results"].nil?

        if (existing = Postcode.find_by(postcode: postcode))
          existing.update(results: json["results"], updated_at: Time.now) if update
        else
          Postcode.create!(postcode: postcode, results: json["results"])
        end
        build_locations(json["results"])
      rescue JSON::ParserError
        raise UnexpectedResponse
      end
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

    def build_locations(results)
      locations = results.map do |result|
        LocationBuilder.new(result).build_location
      end

      {
        "average_latitude" => locations.sum(&:latitude) / locations.size.to_f,
        "average_longitude" => locations.sum(&:longitude) / locations.size.to_f,
        "results" => locations,
      }
    end
  end
end
