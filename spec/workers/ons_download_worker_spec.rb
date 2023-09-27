require "spec_helper"

RSpec.describe OnsDownloadWorker do
  let(:s3_client) { double("s3_client") }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
  end

  describe "#perform" do
    context "with a valid URL" do
      before do
        stub_request(:get, "https://test.com/ONSPD_JUN_2023_UK.zip").to_return(
          status: 200,
          body: ->(_) { File.new("#{Rails.root}/spec/fixtures/ONSPD_JUN_2023_UK.zip") },
        )
      end

      it "grabs a file from the download URL, extracts the zip, creates S3 objects, and creates OnsImportWorkers" do
        expect(s3_client).to receive(:put_object).twice

        expect(OnsImportWorker).to receive(:perform_async).with("Data/multi_csv/ONSPD_JUN_2023_UK_AB.csv")
        expect(OnsImportWorker).to receive(:perform_async).with("Data/multi_csv/ONSPD_JUN_2023_UK_AL.csv")

        OnsDownloadWorker.new.perform("https://test.com/ONSPD_JUN_2023_UK.zip")
      end
    end

    context "with an invalid URL" do
      before do
        stub_request(:get, "https://test.com/ONSPD_JUN_2023_UK.zip").to_return(
          status: 200,
          body: "hello",
        )
      end

      it "grabs a file from the download URL, extracts the zip, creates S3 objects, and creates OnsImportWorkers" do
        expect(GovukError).to receive(:notify)
        OnsDownloadWorker.new.perform("https://test.com/ONSPD_JUN_2023_UK.zip")
      end
    end
  end
end
