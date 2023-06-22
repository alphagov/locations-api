require "spec_helper"

RSpec.describe ProcessPostcodeWorker do
  describe "#perform" do
    let(:postcode) { "E18QS" }

    it "updates the given postcode" do
      stubbed_client = double("PostcodeManager")

      expect(PostcodeManager).to receive(:new) { stubbed_client }
      expect(stubbed_client).to receive(:update_postcode).with(postcode)

      ProcessPostcodeWorker.new.perform(postcode)
    end

    it "notifies Sentry when an OS Places API Client exception is raised" do
      allow(OsPlacesApi::Client).to receive(:new).and_raise(OsPlacesApi::RateLimitExceeded.new)

      expect(GovukError).to receive(:notify).with(OsPlacesApi::RateLimitExceeded)

      ProcessPostcodeWorker.new.perform(postcode)
    end
  end
end
