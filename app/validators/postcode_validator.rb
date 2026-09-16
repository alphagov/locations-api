class PostcodeValidator < ActiveModel::Validator
  VALID_POSTCODE = /^([A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2})$/i
  INVALID_POSTCODE = /^(BF|BX|GIR|XX|AI|GX|VG)/i
  CAYMANS_POSTCODE = /^KY[0-9]-/i

  def validate(record)
    return if valid_postcode?(record.postcode) && !invalid_postcode?(record.postcode)

    record.errors.add :postcode, "This postcode is invalid"
  end

  def valid_postcode?(postcode)
    PostcodeHelper.normalise(postcode).match?(VALID_POSTCODE)
  end

  def invalid_postcode?(postcode)
    PostcodeHelper.normalise(postcode).match?(INVALID_POSTCODE) || postcode.match?(CAYMANS_POSTCODE)
  end
end
