require "spec_helper"

RSpec.describe "Locations V1 API" do
  before do
    ENV["OS_PLACES_API_KEY"] = "some_key"
    ENV["OS_PLACES_API_SECRET"] = "some_secret"
  end

  context "Successful call" do
    let(:postcode) { "E1 8QS" }
    let(:locations) do
      [
        Location.new(postcode: "E1 8QS",
                     address: "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
                     latitude: 51.5144547,
                     longitude: -0.0729933,
                     local_custodian_code: 5900),
        Location.new(postcode: "E1 8QS",
                     address: "2, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
                     latitude: 51.5144548,
                     longitude: -0.0729934,
                     local_custodian_code: 5900),
      ]
    end

    before do
      client = double("client")
      allow(OsPlacesApi::Client).to receive(:new).and_return(client)
      expect(client).to receive(:locations_for_postcode).with(postcode).and_return(locations)
    end

    it "Should return proper body" do
      get "/v1/locations?postcode=#{postcode}"

      expect(response.body).to eq locations.to_json
    end
  end

  context "Client request validation" do
    let(:expected_validation_response) do
      { errors: { postcode: ["This postcode is invalid"] } }.to_json
    end

    context "Postcode is incorrect" do
      let(:postcode) { "AAA 1AA" }
      it "Should return error when postcode is incorrect" do
        get "/v1/locations?postcode=#{postcode}"

        expect(response.body).to eq expected_validation_response
      end
    end

    context "Postcode is not provided" do
      it "Should return error when postcode is not provided" do
        get "/v1/locations"

        expect(response.body).to eq expected_validation_response
      end
    end
  end
end
