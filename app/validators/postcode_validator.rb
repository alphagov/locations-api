class PostcodeValidator < ActiveModel::Validator
  VALID_POSTCODE = /^([A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2})$/i
  INVALID_POSTCODE = /^(BF|BX|GIR|XX|GY|JE|IM|AI|GX|KY|VG)/i

  def validate(record)
    postcode = PostcodeHelper.normalise(record.postcode)
    return if postcode.match?(VALID_POSTCODE) && !postcode.match?(INVALID_POSTCODE)

    record.errors.add :postcode, "This postcode is invalid"
  end
end
