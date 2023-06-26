class Location
  include ActiveModel::Model

  attr_accessor :address, :longitude, :latitude, :local_custodian_code

  def to_hash
    {
      "address" => address,
      "longitude" => longitude,
      "latitude" => latitude,
      "local_custodian_code" => local_custodian_code,
    }
  end
end
