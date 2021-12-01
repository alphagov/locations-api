require "spec_helper"

RSpec.describe "Locations V1 API" do
  let(:location1) do
    Location.new(postcode: "E1 8QS",
                 address: "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
                 latitude: 51.5144547,
                 longitude: -0.0729933,
                 local_custodian_code: 5900)
  end
  let(:location2) do
    Location.new(postcode: "E1 8QS",
                 address: "2, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
                 latitude: 51.5144548,
                 longitude: -0.0729934,
                 local_custodian_code: 5900)
  end

  let(:postcode) do
    "E1 8QS"
  end

  let(:locations) do
    [location1, location2]
  end

  let(:token_manager) { double("token_manager") }
  let(:client) { double("client") }

  before do
    ENV["OS_PLACES_API_KEY"] = "some_key"
    ENV["OS_PLACES_API_SECRET"] = "some_secret"
  end

  context "Successful call" do
    before do
      allow(OsPlacesApi::Client).to receive(:new).and_return(client)
      expect(client).to receive(:locations_for_postcode).with(postcode).and_return(locations)
    end

    it "Should return proper body" do
      get "/v1/locations?postcode=#{postcode}"

      expect(response.body).to eq locations.to_json
    end
  end
end
