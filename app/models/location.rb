class Location
  include ActiveModel::Model

  attr_accessor :postcode, :address, :latitude, :longitude, :local_custodian_code
end
