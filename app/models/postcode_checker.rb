class PostcodeChecker
  include ActiveModel::Model

  attr_accessor :postcode

  validates :postcode, postcode: true
end
