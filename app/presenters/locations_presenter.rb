class LocationsPresenter
  def self.instance_for(postcode)
    OsPlacesLocationsPresenter.new(postcode)
  end

  def initialize(postcode)
    @postcode = postcode
  end
end
