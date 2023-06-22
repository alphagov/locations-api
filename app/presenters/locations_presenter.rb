class LocationsPresenter
  def self.instance_for(postcode)
    case postcode.source
    when "os_places"
      OsPlacesLocationsPresenter.new(postcode)
    when "onspd"
      OnspdLocationsPresenter.new(postcode)
    end
  end

  def initialize(postcode)
    @postcode = postcode
  end
end
