module PostcodeHelper
  DISALLOWED_CHARS = /[`~,.<>;':"\/\[\]|{}()=_+-]|\s/.freeze

  def self.normalise(postcode)
    postcode.to_s.gsub(DISALLOWED_CHARS, "").upcase
  end
end
