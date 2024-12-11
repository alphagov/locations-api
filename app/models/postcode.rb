class Postcode < ApplicationRecord
  validates_with PostcodeValidator
  validates :postcode, uniqueness: true
  before_validation :normalize_postcode

  enum :source, %i[os_places onspd].index_with(&:to_s)
  scope :active, -> { where(retired: false) }
  scope :retired, -> { where(retired: true) }

private

  def normalize_postcode
    self["postcode"] = PostcodeHelper.normalise(self["postcode"])
  end
end
