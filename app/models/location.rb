class Location
  include ActiveModel::Model

  attr_accessor :postcode, :address, :latitude, :longitude, :local_custodian_code

  def ==(other)
    postcode == other.postcode &&
      address == other.address &&
      latitude == other.latitude &&
      longitude == other.longitude &&
      local_custodian_code == other.local_custodian_code
  end
end
