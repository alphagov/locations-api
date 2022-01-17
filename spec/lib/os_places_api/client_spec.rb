require "spec_helper"

RSpec.describe OsPlacesApi::Client do
  describe "#locations_for_postcode" do
    let(:client) do
      described_class.new(instance_double("AccessTokenManager", access_token: "some token"))
    end
    let(:postcode) { "E18QS" }
    let(:api_endpoint) { "https://api.os.uk/search/places/v1/postcode?output_srs=WGS84&postcode=#{postcode}" }
    let(:os_places_api_results) do
      [
        {
          "DPA" => {
            "UPRN" => "6714279",
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
        # subsequent results omitted for brevity
      ]
    end
    let(:location) do
      Location.new(address: "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
                   latitude: 51.5144547,
                   local_custodian_code: 5900,
                   longitude: -0.0729933,
                   postcode: "E1 8QS")
    end

    context "the postcode doesn't exist in the database" do
      before :each do
        Postcode.where(postcode: postcode).map(&:destroy)
      end

      it "should query OS Places API and return results" do
        api_response = {
          "header": {
            "uri": api_endpoint,
            "query": "postcode=#{postcode}",
            "offset": 0,
            "totalresults": 1, # really 12, but we've omitted the other 11 in `results` above
            "format": "JSON",
            "dataset": "DPA",
            "lr": "EN,CY",
            "maxresults": 100,
            "epoch": "87",
            "output_srs": "WGS84",
          },
          "results": os_places_api_results,
        }
        stub_request(:get, api_endpoint)
          .to_return(status: 200, body: api_response.to_json)

        expect(client.locations_for_postcode(postcode).as_json).to eq([location].as_json)
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
      before do
        Postcode.create(postcode: postcode, results: os_places_api_results)
      end

      it "should return the cached data" do
        expect(a_request(:get, api_endpoint)).not_to have_been_made

        expect(client.locations_for_postcode(postcode)).to eq([location])
      end
    end

    context "the postcode is invalid" do
      let(:postcode) { "foo" }

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
end
