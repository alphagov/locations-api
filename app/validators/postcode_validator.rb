class PostcodeValidator < ActiveModel::Validator
  def validate(record)
    return if Postcodes::Utils.categorise(record.postcode) == Postcodes::Type::UK

    record.errors.add :postcode, "This postcode is invalid"
  end
end
