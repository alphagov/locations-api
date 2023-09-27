module OsPlacesApi
  class LocationResults
    NATIONAL_AUTHORITIES = ["ORDNANCE SURVEY", "HIGHWAYS ENGLAND"].freeze

    attr_reader :results

    def initialize(results)
      @results = results
    end

    def any_locations?
      !filtered_locations.empty?
    end

    def empty?
      results.nil? || filtered_locations.empty?
    end

    def filtered_locations
      filtered_hash = results_hash_with_uniq_uprns.reject do |r|
        (NATIONAL_AUTHORITIES.include? r["LOCAL_CUSTODIAN_CODE_DESCRIPTION"]) ||
          (r["POSTAL_ADDRESS_CODE"] == "N")
      end
      hash_to_locations(filtered_hash)
    end

    def unfiltered_locations
      hash_to_locations(results_hash_with_uniq_uprns)
    end

    def hash_to_locations(results_hash)
      results_hash.map { |result_hash| build_location(result_hash) }
    end

    def results_hash_with_uniq_uprns
      results.map { |result| result[result.keys.first] } # first key is either "LPI" or "DPA"
        .uniq { |result_hash| result_hash["UPRN"] }
    end

    def build_location(result_hash)
      Location.new(address: result_hash["ADDRESS"],
                   latitude: result_hash["LAT"],
                   longitude: result_hash["LNG"],
                   local_custodian_code: result_hash["LOCAL_CUSTODIAN_CODE"])
    end
  end
end
