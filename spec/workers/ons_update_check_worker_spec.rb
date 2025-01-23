require "spec_helper"

UPDATE_RSS = "".freeze
NO_UPDATE_RSS = "".freeze

RSpec.describe OnsUpdateCheckWorker do
  describe "#perform" do
    context "with no applicable update in the RSS feed" do
      before do
        stub_request(:get, "https://geoportal.statistics.gov.uk/api/feed/rss/2.0?q=PRD_ONSPD&sort=Date%20Created%7Ccreated%7Cdesc").to_return(body: ons_rss(last_updated: Time.zone.now - 1.month))
      end

      context "with no existing import records" do
        it "starts an OnsDownloadWorker" do
          expect(OnsDownloadWorker).to receive(:perform_async).with("https://www.arcgis.com/sharing/rest/content/items/abc123/data")
          OnsUpdateCheckWorker.new.perform
        end
      end

      context "with existing import records" do
        before do
          Import.create!(created_at: Time.zone.now - 1.day)
        end

        it "does nothing" do
          expect(OnsDownloadWorker).not_to receive(:perform_async)
          OnsUpdateCheckWorker.new.perform
        end
      end
    end

    context "with a new update in the RSS feed" do
      before do
        Import.create!(created_at: Time.zone.now - 1.day)
        stub_request(:get, "https://geoportal.statistics.gov.uk/api/feed/rss/2.0?q=PRD_ONSPD&sort=Date%20Created%7Ccreated%7Cdesc").to_return(body: ons_rss)
      end

      it "starts an OnsDownloadWorker" do
        expect(OnsDownloadWorker).to receive(:perform_async).with("https://www.arcgis.com/sharing/rest/content/items/abc123/data")
        OnsUpdateCheckWorker.new.perform
      end
    end

    context "with a new update in the RSS feed but the item is broken" do
      before do
        Import.create!(created_at: Time.zone.now - 1.day)
        stub_request(:get, "https://geoportal.statistics.gov.uk/api/feed/rss/2.0?q=PRD_ONSPD&sort=Date%20Created%7Ccreated%7Cdesc").to_return(body: broken_ons_rss)
      end

      it "raises an error and does not start an OnsDownloadWorker" do
        expect(OnsDownloadWorker).not_to receive(:perform_async).with("https://www.arcgis.com/sharing/rest/content/items/abc123/data")
        expect { OnsUpdateCheckWorker.new.perform }.to raise_error(StandardError)
        expect(Import.count).to eq(1)
      end
    end
  end
end
