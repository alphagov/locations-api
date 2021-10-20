require "spec_helper"

RSpec.describe OsPlacesApi::Client do
  describe "#locations_for_postcode" do
    let(:client) do
      described_class.new(instance_double("AccessTokenManager", access_token: "some token"))
    end

    let(:postcode) { "E18QS" }
    let(:api_endpoint) { "https://api.os.uk/search/places/v1/postcode?postcode=#{postcode}" }

    it "should return results for the provided postcode" do
      results = [
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
      api_response = {
        "header": {
          "uri": "https://api.os.uk/search/places/v1/postcode?postcode=#{postcode}",
          "query": "postcode=#{postcode}",
          "offset": 0,
          "totalresults": 1, # really 12, but we've omitted the other 11 in `results` above
          "format": "JSON",
          "dataset": "DPA",
          "lr": "EN,CY",
          "maxresults": 100,
          "epoch": "87",
          "output_srs": "EPSG:27700",
        },
        "results": results,
      }
      stub_request(:get, api_endpoint).to_return(status: 200, body: api_response.to_json)

      expect(client.locations_for_postcode(postcode)).to eq(results)
    end

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
end