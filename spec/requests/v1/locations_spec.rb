require "spec_helper"

RSpec.describe "Locations V1 API" do
  before do
    ENV["OS_PLACES_API_KEY"] = "some_key"
    ENV["OS_PLACES_API_SECRET"] = "some_secret"
  end

  context "Successful call for an OS Places API postcode" do
    let(:postcode) { "E1 8QS" }
    let(:normalised_postcode) { "E18QS" }
    let(:address1) do
      {
        address: "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
        latitude: 51.5144547,
        longitude: -0.0729933,
        local_custodian_code: 5900,
      }
    end
    let(:address2) do
      {
        address: "2, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
        latitude: 51.5144545,
        longitude: -0.0729935,
        local_custodian_code: 5900,
      }
    end
    let(:api_locations) do
      [
        { "DPA" => address1 },
        { "DPA" => address2 },
      ]
    end
    let(:locations) do
      {
        "source" => "Ordnance Survey",
        "average_longitude" => -0.07298533333333333,
        "average_latitude" => 51.51446256666667,
        "results" => [Location.new(address1), Location.new(address2)],
      }
    end

    before do
      client = double("client")
      allow(OsPlacesApi::Client).to receive(:new).and_return(client)
      expect(client).to(receive(:retrieve_locations_for_postcode).with(normalised_postcode)).and_return(OsPlacesApi::LocationResults.new(os_places_api_results))
    end

    it "Should return proper body" do
      get "/v1/locations?postcode=#{postcode}"

      expect(response.body).to eq locations.to_json
    end
  end

  context "Successful call for an ONSPD postcode" do
    let(:postcode) { "AB1 0AA" }
    let(:normalised_postcode) { "AB10AA" }

    context "which is small and non-retired" do
      let(:locations) do
        {
          "source" => "Office of National Statistics",
          "average_longitude" => -2.242851,
          "average_latitude" => 57.101474,
          "results" => [],
          "extra_information" => {
            "source" => "ONS source updated infrequently",
          },
        }
      end
      let(:results) do
        [
          {
            "ONS" => {
              "AVG_LNG" => -2.242851,
              "AVG_LAT" => 57.101474,
              "TYPE" => "S",
              "DOTERM" => "",
            },
          },
        ]
      end

      before do
        Postcode.create!(postcode: normalised_postcode, source: :onspd, retired: false, results:)
      end

      it "Should return proper body with source warning" do
        get "/v1/locations?postcode=#{postcode}"

        expect(response.body).to eq locations.to_json
      end
    end

    context "which is large and retired" do
      let(:locations) do
        {
          "source" => "Office of National Statistics",
          "average_longitude" => -2.242851,
          "average_latitude" => 57.101474,
          "results" => [],
          "extra_information" => {
            "source" => "ONS source updated infrequently",
            "retired" => "Postcode was retired in April 2004",
            "large" => "Postcode is a large user postcode",
          },
        }
      end
      let(:results) do
        [
          {
            "ONS" => {
              "AVG_LNG" => -2.242851,
              "AVG_LAT" => 57.101474,
              "TYPE" => "L",
              "DOTERM" => "April 2004",
            },
          },
        ]
      end

      before do
        Postcode.create!(postcode: normalised_postcode, source: :onspd, retired: true, results:)
      end

      it "Should return proper body with source, size, and retirement warning" do
        get "/v1/locations?postcode=#{postcode}"

        expect(response.body).to eq locations.to_json
      end
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

  context "Call for a postcode not in OS Places API datasets" do
    let(:postcode) { "E1 8QS" }
    let(:normalised_postcode) { "E18QS" }
    let(:expected_validation_response) do
      { errors: { postcode: ["No results found for given postcode"] } }.to_json
    end

    before do
      client = double("client")
      allow(OsPlacesApi::Client).to receive(:new).and_return(client)
      expect(client).to receive(:retrieve_locations_for_postcode).with(normalised_postcode).and_raise(OsPlacesApi::NoResultsForPostcode)
    end

    it "Should return proper body with error message" do
      get "/v1/locations?postcode=#{postcode}"

      expect(response.body).to eq expected_validation_response
    end

    it "Should return 404 to the upstream app" do
      get "/v1/locations?postcode=#{postcode}"

      expect(response.status).to eq 404
    end
  end

  context "When the postcode passes our validity check but OS Places API says it is invalid" do
    let(:postcode) { "AB12 3CD" }
    let(:normalised_postcode) { "AB123CD" }
    let(:expected_validation_response) do
      { errors: { postcode: ["Invalid postcode provided"] } }.to_json
    end

    before do
      client = double("client")
      allow(OsPlacesApi::Client).to receive(:new).and_return(client)
      expect(client).to receive(:retrieve_locations_for_postcode).with(normalised_postcode).and_raise(OsPlacesApi::InvalidPostcodeProvided)
    end

    it "Should return proper body with error message" do
      get "/v1/locations?postcode=#{postcode}"

      expect(response.body).to eq expected_validation_response
    end

    it "Should return 400 to the upstream app" do
      get "/v1/locations?postcode=#{postcode}"

      expect(response.status).to eq 400
    end
  end

  context "When OS places API returns an unexpected response" do
    let(:postcode) { "AB12 3CD" }
    let(:normalised_postcode) { "AB123CD" }

    before do
      client = double("client")
      allow(OsPlacesApi::Client).to receive(:new).and_return(client)
      expect(client).to receive(:retrieve_locations_for_postcode).with(normalised_postcode).and_raise(OsPlacesApi::UnexpectedResponse)
    end

    it "Should report the error to Sentry, tagged with the postcode" do
      expect(Sentry).to receive(:capture_exception).and_wrap_original do |original, *args, **kwargs|
        expect(Sentry.get_current_scope.tags).to include(postcode: normalised_postcode)
        original.call(*args, **kwargs)
      end

      expect { get "/v1/locations?postcode=#{postcode}" }.to raise_error(OsPlacesApi::UnexpectedResponse)
    end
  end

  context "If the database is corrupted with invalid source information" do
    let(:postcode) { "AB1 0AA" }
    let(:normalised_postcode) { "AB10AA" }

    before do
      record = Postcode.create!(postcode: normalised_postcode, source: :onspd, retired: false, results: [])
      ActiveRecord::Base.connection.execute("UPDATE postcodes SET source='unknown' WHERE id=#{record.id}")
    end

    it "returns a 500 to the upstream app" do
      expect { get "/v1/locations?postcode=#{postcode}" }.to raise_error(LocationsPresenter::UnknownSource)
    end
  end
end
