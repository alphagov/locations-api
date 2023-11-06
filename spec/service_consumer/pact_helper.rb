ENV["PACT_DO_NOT_TRACK"] = "true"

require "pact/provider/rspec"
require "webmock/rspec"
require "factory_bot_rails"
require ::File.expand_path("../../config/environment", __dir__)

Pact.configure do |config|
  config.reports_dir = "spec/reports/pacts"
  config.include WebMock::API
  config.include WebMock::Matchers
  config.include FactoryBot::Syntax::Methods
end

WebMock.allow_net_connect!

def url_encode(str)
  ERB::Util.url_encode(str)
end

Pact.service_provider "Locations API" do
  honours_pact_with "GDS API Adapters" do
    if ENV["PACT_URI"]
      pact_uri(ENV["PACT_URI"])
    else
      base_url = "https://govuk-pact-broker-6991351eca05.herokuapp.com"
      path = "pacts/provider/#{url_encode(name)}/consumer/#{url_encode(consumer_name)}"
      version_modifier = "versions/#{url_encode(ENV.fetch('PACT_CONSUMER_VERSION', 'branch-main'))}"

      pact_uri("#{base_url}/#{path}/#{version_modifier}")
    end
  end
end

Pact.provider_states_for "GDS API Adapters" do
  set_up do
    ENV["OS_PLACES_API_KEY"] = "some_key"
    ENV["OS_PLACES_API_SECRET"] = "some_secret"
  end

  tear_down do
    postcode = Postcode.find_by(postcode: "SW1A1AA")
    postcode.destroy unless postcode.nil?
  end

  provider_state "a postcode" do
    set_up do
      Postcode.create(postcode: "SW1A1AA", results: [
        {
          "DPA" => {
            "UPRN" => "6714278",
            "POSTCODE" => "SW1A1AA",
            "LNG" => -0.1415870,
            "LAT" => 51.5010096,
            "LOCAL_CUSTODIAN_CODE" => 5900,
          },
        },
        {
          "DPA" => {
            "UPRN" => "6714279",
            "POSTCODE" => "SW1A1AA",
            "LNG" => -0.1415871,
            "LAT" => 51.5010097,
            "LOCAL_CUSTODIAN_CODE" => 5901,
          },
        },
      ])
    end
  end
end
