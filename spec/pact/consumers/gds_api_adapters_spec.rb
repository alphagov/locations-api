ENV["PACT_DO_NOT_TRACK"] = "true"

require "pact/v2"
require "pact/v2/rspec"

RSpec.describe "Verify pacts from GDS API Adapter", :pact_v2 do
  Pact::V2.configure do |config|
    config.before_provider_state_setup do
    end

    config.after_provider_state_teardown do
    end
  end

  http_pact_provider "Locations API", opts: {
    http_port: 9292,
    pact_uri: ENV["PACT_URI"],
    broker_url: ENV.fetch("PACT_BROKER_BASE_URL", "https://govuk-pact-broker-6991351eca05.herokuapp.com"),
    consumer_name: "GDS API Adapters",
    consumer_version_selectors: [
      { branch: ENV.fetch("PACT_CONSUMER_VERSION", "branch-main").delete_prefix("branch-") },
    ],
    log_level: :info,
    fail_if_no_pacts_found: true,
  }

  provider_state "a postcode" do
    set_up do
      ENV["OS_PLACES_API_KEY"] = "some_key"
      ENV["OS_PLACES_API_SECRET"] = "some_secret"

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

    tear_down do
      postcode = Postcode.find_by(postcode: "SW1A1AA")
      postcode.destroy unless postcode.nil?
    end
  end
end
