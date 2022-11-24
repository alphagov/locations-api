require "httparty"

module OsPlacesApi
  class Client
    def initialize(token_manager)
      @token_manager = token_manager
    end

    def locations_for_postcode(postcode)
      postcode = PostcodeHelper.normalise(postcode)
      if (record = Postcode.find_by(postcode:))
        return build_locations(record["results"])
      end

      response = get_api_response(postcode)
      raise NoResultsForPostcode if response["results"].nil?

      if any_locations?(response["results"]) && !Postcode.find_by(postcode:)
        Postcode.create!(postcode:, results: response["results"])
      end
      build_locations(response["results"])
    end

    def update_postcode(postcode)
      postcode = PostcodeHelper.normalise(postcode)
      response = get_api_response(postcode)
      record = Postcode.find_by(postcode:)

      if response["results"].nil? || !any_locations?(response["results"])
        record.destroy unless record.nil?
      elsif record.nil?
        Postcode.create!(postcode:, results: response["results"])
      else
        record.update(results: response["results"]) && record.touch
      end
    end

  private

    NATIONAL_AUTHORITIES = ["ORDNANCE SURVEY", "HIGHWAYS ENGLAND"].freeze

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

    def results_hash_with_uniq_uprns(results)
      results.map { |result| result[result.keys.first] } # first key is either "LPI" or "DPA"
        .uniq { |result_hash| result_hash["UPRN"] }
    end

    def hash_to_locations(results_hash)
      results_hash.map { |result_hash| LocationBuilder.new(result_hash).build_location }
    end

    def filtered_locations(results)
      filtered_hash = results_hash_with_uniq_uprns(results).reject { |r| NATIONAL_AUTHORITIES.include? r["LOCAL_CUSTODIAN_CODE_DESCRIPTION"] }
      hash_to_locations(filtered_hash)
    end

    def unfiltered_locations(results)
      hash_to_locations(results_hash_with_uniq_uprns(results))
    end

    def any_locations?(results)
      !filtered_locations(results).empty?
    end

    def build_locations(results)
      locations = unfiltered_locations(results)

      raise NoResultsForPostcode if locations.empty?

      {
        "average_latitude" => locations.sum(&:latitude) / locations.size.to_f,
        "average_longitude" => locations.sum(&:longitude) / locations.size.to_f,
        "results" => filtered_locations(results),
      }
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
