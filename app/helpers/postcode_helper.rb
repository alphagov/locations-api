module PostcodeHelper
  DISALLOWED_CHARS = /[`~,.<>;':"\/\[\]|{}()=_+-]|\s/

  def self.normalise(postcode)
    postcode.to_s.gsub(DISALLOWED_CHARS, "").upcase
  end
end
