require "spec_helper"

RSpec.describe OsPlacesApi::AccessTokenManager do
  describe "#initialize" do
    it "raises an exception when both ENV variables are missing" do
      expect { init_token_manager(os_places_api_key: nil, os_places_api_secret: nil) }
        .to raise_error(OsPlacesApi::MissingOsPlacesApiCredentials)
    end

    it "raises an exception when only the OS_PLACES_API_KEY ENV variable is missing" do
      expect { init_token_manager(os_places_api_key: nil, os_places_api_secret: "secret") }
        .to raise_error(OsPlacesApi::MissingOsPlacesApiCredentials)
    end

    it "raises an exception when only the OS_PLACES_API_SECRET ENV variable is missing" do
      expect { init_token_manager(os_places_api_key: "key", os_places_api_secret: nil) }
        .to raise_error(OsPlacesApi::MissingOsPlacesApiCredentials)
    end

    it "doesn't raise an exception when both ENV variables are present" do
      expect { init_token_manager(os_places_api_key: "key", os_places_api_secret: "secret") }
        .not_to raise_error
    end
  end

  describe "#access_token" do
    let(:access_token_manager) do
      init_token_manager(os_places_api_key: "key", os_places_api_secret: "secret")
    end
    let(:os_places_api_endpoint) { "https://api.os.uk/oauth2/token/v1" }

    it "raises an exception if the API credentials aren't accepted" do
      stub_request(:post, os_places_api_endpoint)
        .to_return(status: 401, body: { "ErrorCode": "invalid_client", "Error": "Client credentials are invalid" }.to_json)

      expect { access_token_manager.access_token }.to raise_error(OsPlacesApi::InvalidOsPlacesApiCredentials)
    end

    it "returns an access token if the API credentials are accepted" do
      access_token = "Abc123Def456Ghi789"
      stub_request(:post, os_places_api_endpoint)
        .to_return(status: 200, body: { "access_token": access_token, "expires_in": "299", "issued_at": "1634663382476", "token_type": "Bearer" }.to_json)

      expect(access_token_manager.access_token).to eq(access_token)
    end
  end

  def init_token_manager(os_places_api_key:, os_places_api_secret:)
    ClimateControl.modify(OS_PLACES_API_KEY: os_places_api_key, OS_PLACES_API_SECRET: os_places_api_secret) do
      described_class.new
    end
  end
end
