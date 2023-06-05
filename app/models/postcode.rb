class Postcode < ApplicationRecord
  validates_with PostcodeValidator
  validates :postcode, uniqueness: true
  before_validation :normalize_postcode

  enum source: { os_places: 0, onspd: 1 }
  scope :active, -> { where(retired: false) }
  scope :retired, -> { where(retired: true) }

private

  def normalize_postcode
    self["postcode"] = PostcodeHelper.normalise(self["postcode"])
  end
end
