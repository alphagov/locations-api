require "spec_helper"

RSpec.describe OsPlacesApi::LocationResults do
  let(:results) { OsPlacesApi::LocationResults.new(os_places_api_results) }
  let(:filterable_results) { OsPlacesApi::LocationResults.new(os_places_api_results_with_filterable_locations) }
  let(:postal_address_code_n_results) { OsPlacesApi::LocationResults.new(os_places_api_results_with_postal_address_code_n) }

  describe "#any_locations?" do
    it "should be true for normal results" do
      expect(results.any_locations?).to be(true)
    end

    it "should be false with filtered results" do
      expect(filterable_results.any_locations?).to be(false)
    end
  end

  describe "#empty?" do
    it "should be false for normal results" do
      expect(results.empty?).to be(false)
    end

    it "should be true with filtered results" do
      expect(filterable_results.empty?).to be(true)
    end
  end

  describe "#filtered_locations" do
    it "should return results filtering out duplicate UPRNs and HIGHWAY ENGLAND/ORDNANCE SURVEY records" do
      expect(results.filtered_locations.count).to eq(2)
    end

    it "should return results but filter out record with POSTAL_ADDRESS_CODE='N'" do
      expect(postal_address_code_n_results.filtered_locations.count).to eq(1)
    end
  end

  describe "#unfiltered_locations" do
    it "should return results filtering out duplicate UPRNs" do
      expect(results.unfiltered_locations.count).to eq(3)
    end

    it "should return results without filtering POSTAL_ADDRESS_CODE='N'" do
      expect(postal_address_code_n_results.unfiltered_locations.count).to eq(3)
    end
  end
end
