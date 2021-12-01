module OsPlacesApi
  class LocationBuilder
    def initialize(result)
      @result = result
    end

    def build_location
      Location.new(postcode: @result.dig("DPA", "POSTCODE"),
                   address: @result.dig("DPA", "ADDRESS"),
                   latitude: @result.dig("DPA", "LAT"),
                   longitude: @result.dig("DPA", "LNG"),
                   local_custodian_code: @result.dig("DPA", "LOCAL_CUSTODIAN_CODE"))
    end
  end
end
