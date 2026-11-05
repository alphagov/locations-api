require "spec_helper"

RSpec.describe Postcodes::Utils do
  describe ".categorise" do
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

    let(:crown_dependency_postcodes) do
      [
        "JE4 3ZZ", # Jersey
        "GY7 3ZZ", # Guernsey
        "IM5 3ZZ", # Isle of Man
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

    it "categorises all valid uk postcodes correctly" do
      valid_postcodes.each do |postcode|
        expect(described_class.categorise(postcode)).to eq(Postcodes::Type::UK), "#{postcode} should be valid"
      end
    end

    it "categorises all crown dependency postcodes correctly" do
      crown_dependency_postcodes.each do |postcode|
        expect(described_class.categorise(postcode)).to eq(Postcodes::Type::CROWN_DEPENDENCY), "#{postcode} should be valid"
      end
    end

    it "categorises all invalid postcodes correctly" do
      invalid_postcodes.each do |postcode|
        expect(described_class.categorise(postcode)).to eq(Postcodes::Type::INVALID), "#{postcode} should be invalid"
      end
    end
  end

  describe ".normalise" do
    it "converts a postcode with spaces and mixed case into a standard format" do
      expect(described_class.normalise(" SW12 1aa ")).to eq("SW121AA")
    end

    it "cuts out odd characters" do
      expect(described_class.normalise("SW121AA[]")).to eq("SW121AA")
    end
  end
end
