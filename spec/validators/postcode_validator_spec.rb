require "spec_helper"

class SomeModelWithPostcode
  include ActiveModel::Validations
  validates_with PostcodeValidator
  attr_accessor :postcode

  def initialize(postcode)
    @postcode = postcode
  end
end

RSpec.describe PostcodeValidator do
  let(:valid_postcodes) do
    [
      "W22 3AB",
      "w22 3ab",
      "W223AB",
      "w223ab",
      " W22 3AB",
      "W22  3AB",
      " W22 3AB ",
      "W223AB ",
      "W22-3AB",
      "W22-3AB",
      "W22+3AB",
      "W22/3AB",
      "W223AB",
      "W-22-3AB",
      "W22(3AB)",
      "W_22_3AB",
      "wu 2 3ab",
      "wu23ab",
      "A1 1AA",
      "AA1 1AA",
      "AA11 1AA",
      "A1A 1AA",
      "AA1A 1AA",
      "EC1A 1BB",
      "W1A 0AX",
      "M1 1AE",
      "B33 8TH",
      "CR2 6XH",
      "DN55 1PT",
      "KY11 4JU",
    ]
  end

  let(:invalid_postcodes) do
    [
      "",
      " ",
      "somestring",
      "1AA 1BB",
      "11A 1BB",
      "AA1 ABCDEFG",
      "AA1 12345",
      "AA1",
      "AAA 1AA",
      # Crown dependencies
      "JE4 3ZZ",
      "GY7 3ZZ",
      "IM5 3ZZ",
      # Non-geographic
      "GIR 0AA",
      "BF1",
      "BX8 0HB",
      "XX10 1DD",
      "XX10 1SS",
      # Overseas territories
      "AI8 1AA",
      "ASCN 1AA",
      "BBND 1AA",
      "BIQQ 1AA",
      "FIQQ 1AA",
      "GX5 1AA",
      "GX11 1AA",
      "KY1-1500",
      "KY1-1AA",
      "MSR1330",
      "MSR 1AA",
      "PCRN 1ZZ",
      "SIQQ 1ZZ",
      "STHL 1ZZ",
      "TDCU 1ZZ",
      "TKCA 1ZZ",
      "VG1110",
      "VG 1ZZ",
      nil,
    ]
  end

  context "when postcode is valid" do
    it "is valid" do
      valid_postcodes.each do |postcode|
        expect(SomeModelWithPostcode.new(postcode).valid?).to eq(true), "#{postcode} should be valid"
      end
    end
  end

  context "when postcode is invalid" do
    it "is invalid" do
      invalid_postcodes.each do |postcode|
        expect(SomeModelWithPostcode.new(postcode).valid?).to eq(false), "#{postcode} should be invalid"
      end
    end
  end
end
