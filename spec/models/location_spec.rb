require "spec_helper"

RSpec.describe Location, type: :model do
  subject do
    described_class.new(address: "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
                        latitude: 51.5144547,
                        longitude: -0.0729933,
                        local_custodian_code: 5900)
  end
  describe "Validation" do
    it "is valid with all attributes present" do
      expect(subject).to be_valid
    end

    it "is valid with just some of the attributes" do
      subject.latitude = nil
      subject.longitude = nil

      expect(subject).to be_valid
    end

    it "is valid without any attributes" do
      subject.address = nil
      subject.latitude =  nil
      subject.longitude = nil
      subject.local_custodian_code = nil

      expect(subject).to be_valid
    end
  end
end
