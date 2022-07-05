module OsPlacesApi
  class LocationBuilder
    def initialize(result)
      @result = result
    end

    def build_location
      Location.new(address: @result["ADDRESS"],
                   latitude: @result["LAT"],
                   longitude: @result["LNG"],
                   local_custodian_code: @result["LOCAL_CUSTODIAN_CODE"])
    end
  end
end
