require "spec_helper"

RSpec.describe Postcode, type: :model do
  describe "Normalisation" do
    it "removes disallowed characters from the provided postcode" do
      [
        " ",
        "_",
        "-",
        "+",
        "(",
        ")",
        "/",
      ].each do |char|
        record = Postcode.create(postcode: "E1#{char}8QS")
        expect(record.postcode).to eq("E18QS")
      end
    end

    it "converts postcode to uppercase" do
      record = Postcode.create(postcode: "e18qs")
      expect(record.postcode).to eq("E18QS")
    end

    it "doesn't edit the provided JSON" do
      record = Postcode.create(postcode: "E18 QS", results: '[{"foo":"bar"}]')
      expect(record.results).to eq('[{"foo":"bar"}]')
    end
  end

  describe "Validation" do
    it "successfully validates and stores valid postcodes" do
      expect { Postcode.create!(postcode: "E18QS", results: "{}") }.to_not raise_error
    end

    it "raises an error if the postcode is missing" do
      expect { Postcode.create!(results: "{}") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "prevents the same postcode being stored multiple times" do
      postcode = "E18 QS"
      Postcode.create!(postcode: postcode)
      expect { Postcode.create!(postcode: postcode) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "uses the PostcodeValidator" do
      # Postcode validation logic is already thoroughly tested in
      # postcode_validator_spec.rb, so we don't need to replicate that here.
      # We only want to make sure the Postcode model uses the PostcodeValidator.
      # There doesn't seem to be a way to test that directly, so this is more of
      # an integration test where we give it a known invalid postcode and ensure
      # it raises an error.
      expect { Postcode.create!(postcode: "1AA 1BB") }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
