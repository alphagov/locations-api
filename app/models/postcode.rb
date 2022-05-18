class Postcode < ApplicationRecord
  validates_with PostcodeValidator
  validates :postcode, uniqueness: true
  before_validation :normalize_postcode

private

  def normalize_postcode
    self["postcode"] = PostcodeHelper.normalise(self["postcode"])
  end
end
