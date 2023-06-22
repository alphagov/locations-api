require "spec_helper"

RSpec.describe OsPlacesApi::Client do
  let(:client) do
    described_class.new(instance_double("AccessTokenManager", access_token: "some token"))
  end
  let(:postcode) { "E18QS" }

  describe "#retrieve_locations_for_postcode" do
    it "queries OS Places API and return results" do
      stub_os_places_api_request_good(postcode)

      expect(client.retrieve_locations_for_postcode(postcode).results).to eq(os_places_api_results)
    end

    it "raises an exception if the results are nil" do
      stub_os_places_api_request_nil_results(postcode)

      expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::NoResultsForPostcode)
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
      stub_os_places_api_request(postcode, api_response, status: 401)

      expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::ExpiredAccessToken)
    end

    it "raises an exception if the request is forbidden" do
      stub_os_places_api_request(postcode, {}, status: 403)

      expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::RequestForbidden)
    end

    it "raises an exception if the request cannot resolve" do
      stub_os_places_api_request(postcode, {}, status: 404)

      expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::RequestNotFound)
    end

    it "raises an exception if the request method is not allowed" do
      stub_os_places_api_request(postcode, {}, status: 405)

      expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::MethodNotAllowed)
    end

    it "raises an exception if rate limit exceeded" do
      stub_os_places_api_request(postcode, {}, status: 429)

      expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::RateLimitExceeded)
    end

    it "raises an exception if OS Places API has an internal server error" do
      api_response = {
        "error": {
          "statuscode": 500,
          "message": "The provided request resulted in an internal server error.",
        },
      }
      stub_os_places_api_request(postcode, api_response, status: 500)

      expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::InternalServerError)
    end

    it "raises an exception if the OS Places API service is unavailable" do
      stub_os_places_api_request(postcode, {}, status: 503)

      expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::ServiceUnavailable)
    end

    it "raises an exception if the response isn't in the structure we expect" do
      stub_os_places_api_request_invalid_response(postcode)
      expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::UnexpectedResponse)
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

        stub_os_places_api_request(postcode, api_response, status: 400)

        expect { client.retrieve_locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::InvalidPostcodeProvided)
      end
    end
  end
end
