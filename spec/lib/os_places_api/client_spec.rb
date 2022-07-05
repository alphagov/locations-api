require "spec_helper"

RSpec.describe OsPlacesApi::Client do
  let(:client) do
    described_class.new(instance_double("AccessTokenManager", access_token: "some token"))
  end
  let(:postcode) { "E18QS" }
  let(:api_endpoint) { "https://api.os.uk/search/places/v1/postcode?output_srs=WGS84&postcode=#{postcode}&dataset=DPA,LPI" }
  let(:successful_response) do
    {
      "header": {
        "uri": api_endpoint,
        "query": "postcode=#{postcode}",
        "offset": 0,
        "totalresults": 1, # really 12, but we've omitted the other 11 in `results` above
        "format": "JSON",
        "dataset": "DPA,LPI",
        "lr": "EN,CY",
        "maxresults": 100,
        "epoch": "87",
        "output_srs": "WGS84",
      },
      "results": os_places_api_results,
    }
  end
  let(:os_places_api_results) do
    [
      {
        "DPA" => {
          "UPRN" => "6714278",
          "UDPRN" => "54673874",
          "ADDRESS" => "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
          "BUILDING_NUMBER" => "1",
          "THOROUGHFARE_NAME" => "WHITECHAPEL HIGH STREET",
          "POST_TOWN" => "LONDON",
          "POSTCODE" => "E1 8QS",
          "RPC" => "2",
          "X_COORDINATE" => 533_813.0,
          "Y_COORDINATE" => 181_262.0,
          "LNG" => -0.0729933,
          "LAT" => 51.5144547,
          "STATUS" => "APPROVED",
          "LOGICAL_STATUS_CODE" => "1",
          "CLASSIFICATION_CODE" => "CO01",
          "CLASSIFICATION_CODE_DESCRIPTION" => "Office / Work Studio",
          "LOCAL_CUSTODIAN_CODE" => 5900,
          "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "TOWER HAMLETS",
          "POSTAL_ADDRESS_CODE" => "D",
          "POSTAL_ADDRESS_CODE_DESCRIPTION" => "A record which is linked to PAF",
          "BLPU_STATE_CODE" => "1",
          "BLPU_STATE_CODE_DESCRIPTION" => "Under construction",
          "TOPOGRAPHY_LAYER_TOID" => "osgb1000006035651",
          "LAST_UPDATE_DATE" => "17/06/2017",
          "ENTRY_DATE" => "17/02/2017",
          "BLPU_STATE_DATE" => "17/02/2017",
          "LANGUAGE" => "EN",
          "MATCH" => 1.0,
          "MATCH_DESCRIPTION" => "EXACT",
        },
      },
      {
        "LPI" => {
          "UPRN" => "6714279",
          "ADDRESS" => "2, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
          "USRN" => "22701338",
          "LPI_KEY" => "5900L000449318",
          "PAO_START_NUMBER" => "2",
          "STREET_DESCRIPTION" => "WHITECHAPEL HIGH STREET",
          "TOWN_NAME" => "LONDON",
          "ADMINISTRATIVE_AREA" => "TOWER HAMLETS",
          "POSTCODE_LOCATOR" => "E1 8QS",
          "RPC" => "2",
          "X_COORDINATE" => 533_813.0,
          "Y_COORDINATE" => 181_262.0,
          "LNG" => -0.0729935,
          "LAT" => 51.5144545,
          "STATUS" => "APPROVED",
          "LOGICAL_STATUS_CODE" => "1",
          "CLASSIFICATION_CODE" => "CO01",
          "CLASSIFICATION_CODE_DESCRIPTION" => "Office / Work Studio",
          "LOCAL_CUSTODIAN_CODE" => 5900,
          "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "TOWER HAMLETS",
          "COUNTRY_CODE" => "E",
          "COUNTRY_CODE_DESCRIPTION" => "This record is within England",
          "POSTAL_ADDRESS_CODE" => "D",
          "POSTAL_ADDRESS_CODE_DESCRIPTION" => "A record which is linked to PAF",
          "BLPU_STATE_CODE" => "1",
          "BLPU_STATE_CODE_DESCRIPTION" => "Under construction",
          "TOPOGRAPHY_LAYER_TOID" => "osgb1000006035651",
          "LAST_UPDATE_DATE" => "17/06/2017",
          "ENTRY_DATE" => "17/02/2017",
          "BLPU_STATE_DATE" => "17/02/2017",
          "STREET_STATE_CODE" => "2",
          "STREET_STATE_CODE_DESCRIPTION" => "Open",
          "STREET_CLASSIFICATION_CODE" => "8",
          "STREET_CLASSIFICATION_CODE_DESCRIPTION" => "All vehicles",
          "LPI_LOGICAL_STATUS_CODE" => "1",
          "LPI_LOGICAL_STATUS_CODE_DESCRIPTION" => "APPROVED",
          "LANGUAGE" => "EN",
          "MATCH" => 1.0,
          "MATCH_DESCRIPTION" => "EXACT",
        },
      },
      # subsequent results omitted for brevity
    ]
  end

  describe "#locations_for_postcode" do
    let(:locations) do
      [
        Location.new(address: "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
                     latitude: 51.5144547,
                     local_custodian_code: 5900,
                     longitude: -0.0729933),
        Location.new(address: "2, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
                     latitude: 51.5144545,
                     local_custodian_code: 5900,
                     longitude: -0.0729935),
      ]
    end
    let(:average_latitude) { 51.5144546 }
    let(:average_longitude) { -0.0729934 }

    context "the postcode doesn't exist in the database" do
      before :each do
        Postcode.where(postcode: postcode).map(&:destroy)
      end

      it "should query OS Places API and return results" do
        stub_request(:get, api_endpoint)
          .to_return(status: 200, body: successful_response.to_json)

        expect(client.locations_for_postcode(postcode).as_json).to eq(
          {
            "average_latitude" => average_latitude,
            "average_longitude" => average_longitude,
            "results" => locations.as_json,
          },
        )
      end

      it "should filter out duplicate `UPRN` results from the OS Places API response" do
        os_places_api_results[1]["LPI"]["UPRN"] = os_places_api_results[0]["DPA"]["UPRN"]
        stub_request(:get, api_endpoint)
          .to_return(status: 200, body: successful_response.to_json)

        expect(client.locations_for_postcode(postcode).as_json).to eq(
          {
            "average_latitude" => locations[0].latitude,
            "average_longitude" => locations[0].longitude,
            "results" => [locations[0]].as_json,
          },
        )
      end

      it "should cache the response from a successful request" do
        stub_request(:get, api_endpoint)
          .to_return(status: 200, body: successful_response.to_json)

        expect(Postcode.where(postcode: postcode).count).to eq(0)
        client.locations_for_postcode(postcode)
        expect(Postcode.where(postcode: postcode).count).to eq(1)
      end

      it "raises an exception if the access token has expired" do
        api_response = {
          "fault": {
            "faultstring": "Access Token expired",
            "detail": {
              "errorcode": "keymanagement.service.access_token_expired",
            },
          },
        }
        stub_request(:get, api_endpoint).to_return(status: 401, body: api_response.to_json)

        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::ExpiredAccessToken)
      end

      it "raises an exception if the request is forbidden" do
        stub_request(:get, api_endpoint).to_return(status: 403)

        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::RequestForbidden)
      end

      it "raises an exception if the request cannot resolve" do
        stub_request(:get, api_endpoint).to_return(status: 404)

        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::RequestNotFound)
      end

      it "raises an exception if the request method is not allowed" do
        stub_request(:get, api_endpoint).to_return(status: 405)

        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::MethodNotAllowed)
      end

      it "raises an exception if rate limit exceeded" do
        stub_request(:get, api_endpoint).to_return(status: 429)

        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::RateLimitExceeded)
      end

      it "raises an exception if OS Places API has an internal server error" do
        api_response = {
          "error": {
            "statuscode": 500,
            "message": "The provided request resulted in an internal server error.",
          },
        }
        stub_request(:get, api_endpoint).to_return(status: 500, body: api_response.to_json)

        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::InternalServerError)
      end

      it "raises an exception if the OS Places API service is unavailable" do
        stub_request(:get, api_endpoint).to_return(status: 503)

        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::ServiceUnavailable)
      end

      it "raises an exception if the response isn't in the structure we expect" do
        stub_request(:get, api_endpoint).to_return(status: 200, body: "foo")
        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::UnexpectedResponse)

        stub_request(:get, api_endpoint).to_return(status: 200, body: "{}")
        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::UnexpectedResponse)
      end
    end

    context "the postcode exists in the database" do
      it "should return the cached data" do
        Postcode.create(postcode: postcode, results: os_places_api_results)

        expect(a_request(:get, api_endpoint)).not_to have_been_made

        expect(client.locations_for_postcode(postcode)).to eq(
          {
            "average_latitude" => average_latitude,
            "average_longitude" => average_longitude,
            "results" => locations,
          },
        )
      end

      it "should return the cached data even if the postcode is structured differently in the database" do
        normalised_postcode = "E18QS"
        user_inputted_postcode = "E1 8QS"
        Postcode.create(postcode: normalised_postcode, results: os_places_api_results)

        expect(a_request(:get, api_endpoint)).not_to have_been_made

        expect(client.locations_for_postcode(user_inputted_postcode)).to eq(
          {
            "average_latitude" => average_latitude,
            "average_longitude" => average_longitude,
            "results" => locations,
          },
        )
      end
    end

    context "there are two simultaneous requests for the same (new) postcode" do
      it "should not attempt to create the postcode twice" do
        existing_record = Postcode.create(postcode: postcode, results: os_places_api_results)
        n = 0 # make the first call to `find_by` return `nil`; subsequent calls should work correctly
        allow(Postcode).to receive(:find_by) { (n += 1) == 1 ? nil : existing_record }
        stub_request(:get, api_endpoint)
          .to_return(status: 200, body: successful_response.to_json)

        expect(Postcode).not_to receive(:create!)
        expect(client.locations_for_postcode(postcode)).to eq(
          {
            "average_latitude" => average_latitude,
            "average_longitude" => average_longitude,
            "results" => locations,
          },
        )
      end
    end

    context "the postcode is invalid" do
      let(:postcode) { "FOO" }

      it "raises an exception if an invalid postcode is supplied" do
        api_response = {
          "error": {
            "statuscode": 400,
            "message": "Requested postcode must contain a minimum of the sector plus 1 digit of the district e.g. SO1. Requested postcode was sausage",
          },
        }

        stub_request(:get, api_endpoint).to_return(status: 400, body: api_response.to_json)

        expect { client.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::InvalidPostcodeProvided)
      end
    end
  end

  describe "#update_postcode" do
    it "should query OS Places API and add a new row if postcode doesn't exist" do
      stub_request(:get, api_endpoint)
        .to_return(status: 200, body: successful_response.to_json)

      client.update_postcode(postcode)
      expect(Postcode.where(postcode: postcode).pluck(:results)).to eq([os_places_api_results])
    end

    it "should query OS Places API and update cached data if postcode exists" do
      old_results = os_places_api_results.first["DPA"].dup
      old_results["LNG"] = -1
      old_results["LAT"] = -1
      Postcode.create(postcode: postcode, results: [{ "DPA" => old_results }])
      stub_request(:get, api_endpoint)
        .to_return(status: 200, body: successful_response.to_json)

      client.update_postcode(postcode)
      expect(Postcode.where(postcode: postcode).pluck(:results)).to eq([os_places_api_results])
    end

    it "should query OS Places API and delete the postcode if it was terminated" do
      Postcode.create(postcode: postcode, results: [{}])
      stub_request(:get, api_endpoint)
        .to_return(status: 200, body: {}.to_json)

      expect(Postcode.find_by(postcode: postcode)).not_to eq(nil)
      client.update_postcode(postcode)
      expect(Postcode.find_by(postcode: postcode)).to eq(nil)
    end
  end
end
