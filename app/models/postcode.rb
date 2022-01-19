class Postcode < ApplicationRecord
  validates_with PostcodeValidator
  validates :postcode, uniqueness: true
  before_validation :normalize_postcode

private

  def normalize_postcode
    self["postcode"] = self["postcode"].to_s.gsub(PostcodeValidator::DISALLOWED_CHARS, "").upcase
  end
end
