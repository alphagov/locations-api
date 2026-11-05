module Postcodes
  class Utils
    DISALLOWED_CHARS = /[`~,.<>;':"\/\[\]|{}()=_+-]|\s/

    VALID_POSTCODE_REGEX = /^([A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2})$/i
    CROWN_DEPENDENCY_PREFIXES_REGEX = /^(GY|JE|IM)/i
    INVALID_PREFIXES_REGEX = /^(BF|BX|GIR|XX|AI|GX|VG)/i
    CAYMANS_POSTCODE_REGEX = /^KY[0-9]-/i

    def self.categorise(postcode)
      pc = normalise(postcode)

      return Type::UK if uk_postcode?(pc)
      return Type::CROWN_DEPENDENCY if crown_dependency_postcode?(pc)

      Type::INVALID
    end

    def self.normalise(postcode)
      postcode.to_s.gsub(DISALLOWED_CHARS, "").upcase
    end

    def self.uk_postcode?(normalised_postcode)
      normalised_postcode.match?(VALID_POSTCODE_REGEX) &&
        !normalised_postcode.match?(CROWN_DEPENDENCY_PREFIXES_REGEX) &&
        !normalised_postcode.match?(INVALID_PREFIXES_REGEX) &&
        !normalised_postcode.match?(CAYMANS_POSTCODE_REGEX)
    end

    def self.crown_dependency_postcode?(normalised_postcode)
      normalised_postcode.match?(VALID_POSTCODE_REGEX) &&
        normalised_postcode.match?(CROWN_DEPENDENCY_PREFIXES_REGEX)
    end
  end
end
