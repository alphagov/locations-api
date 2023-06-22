class LocationsPresenter
  class UnknownSource < StandardError; end

  def self.instance_for(postcode)
    case postcode.source
    when "os_places"
      OsPlacesLocationsPresenter.new(postcode)
    when "onspd"
      OnspdLocationsPresenter.new(postcode)
    else
      # Should be unreachable, but maybe if data is corrupted?
      raise(LocationsPresenter::UnknownSource, "Unknown source #{postcode.source}")
    end
  end

  def initialize(postcode)
    @postcode = postcode
  end
end
