require "spec_helper"

RSpec.describe Collectors::GlobalPrometheusCollector do
  before do
    @collector = Collectors::GlobalPrometheusCollector.new
    Rails.cache.delete("metrics:oldest_postcode")
  end

  describe "#type" do
    it "has the correct value" do
      expect(@collector.type).to eq("locations_api_global")
    end
  end

  describe "#metrics" do
    before do
      @postcode = Postcode.create!(postcode: "E18QS", updated_at: Time.zone.now - 2.days)
    end

    it "records the time in days since the oldest postcode's update timestamp" do
      metrics = @collector.metrics

      expect(metrics.first.data.first.last).to eq(2)
    end
  end
end
