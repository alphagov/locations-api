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

    def init_token_manager(os_places_api_key:, os_places_api_secret:)
      ClimateControl.modify(OS_PLACES_API_KEY: os_places_api_key, OS_PLACES_API_SECRET: os_places_api_secret) do
        described_class.new
      end
    end
  end
end
