class Location
  include ActiveModel::Model

  attr_accessor :address, :longitude, :latitude, :local_custodian_code

  def ==(other)
    address == other.address &&
      longitude == other.longitude &&
      latitude == other.latitude &&
      local_custodian_code == other.local_custodian_code
  end

  def to_hash
    {
      "address" => address,
      "longitude" => longitude,
      "latitude" => latitude,
      "local_custodian_code" => local_custodian_code,
    }
  end
end
