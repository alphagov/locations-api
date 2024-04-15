require "spec_helper"

RSpec.describe ProcessPostcodeWorker do
  describe "#perform" do
    let(:postcode) { "E18QS" }

    it "updates the given postcode" do
      stubbed_client = double("PostcodeManager")
      expect(stubbed_client).to receive(:update_postcode).with(postcode)
      expect(PostcodeManager).to receive(:new) { stubbed_client }

      ProcessPostcodeWorker.new.perform(postcode)
    end

    it "records a success in the backoff service" do
      stubbed_client = double("PostcodeManager")
      expect(stubbed_client).to receive(:update_postcode).with(postcode)
      expect(PostcodeManager).to receive(:new) { stubbed_client }

      expect(Rails.application.config.sidekiq_scheduler_backoff_service).to receive(:record_success)

      ProcessPostcodeWorker.new.perform(postcode)
    end

    it "records a failure in the backoff service when an OS Places API Client exception is raised" do
      allow(OsPlacesApi::Client).to receive(:new).and_raise(OsPlacesApi::RateLimitExceeded.new)

      expect(Rails.application.config.sidekiq_scheduler_backoff_service).to receive(:record_failure)

      ProcessPostcodeWorker.new.perform(postcode)
    end
  end
end
