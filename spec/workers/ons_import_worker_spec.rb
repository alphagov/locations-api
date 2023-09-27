require "spec_helper"

RSpec.describe OnsImportWorker do
  let(:s3_client) { double("s3_client") }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
    allow(s3_client).to receive(:get_object)

    Postcode.delete_all
  end

  describe "#perform" do
    context "with a valid key and file" do
      before do
        tempfile_from_fixture("#{Rails.root}/spec/fixtures/ONSPD_JUN_2023_UK_AB.csv")
      end

      it "imports records not present in the database" do
        expect(s3_client).to receive(:get_object).once

        OnsImportWorker.new.perform("ons/JUN_2023/AB.csv")
        expect(Postcode.count).to eq(5)
      end

      it "sets record retired if a valid doterm exists" do
        expect(s3_client).to receive(:get_object).once

        OnsImportWorker.new.perform("ons/JUN_2023/AB.csv")
        record = Postcode.where(postcode: "AB10AA").first
        expect(record.retired).to be true
      end

      it "sets record not retired if doterm is blank" do
        expect(s3_client).to receive(:get_object).once

        OnsImportWorker.new.perform("ons/JUN_2023/AB.csv")
        record = Postcode.where(postcode: "AB10AE").first
        expect(record.retired).to be false
      end
    end

    context "with an existing record" do
      before do
        tempfile_from_fixture("#{Rails.root}/spec/fixtures/ONSPD_JUN_2023_UK_AB.csv")
        Postcode.create(postcode: "AB10AA", source: "onspd", results: [], retired: false)
      end

      it "updates the existing record" do
        expect(s3_client).to receive(:get_object).once

        OnsImportWorker.new.perform("ons/JUN_2023/AB.csv")
        expect(Postcode.count).to eq(5)
        record = Postcode.where(postcode: "AB10AA").first
        expect(record.retired).to be true
        expect(record.results).not_to eq([])
      end
    end

    context "with an existing os_places record" do
      before do
        tempfile_from_fixture("#{Rails.root}/spec/fixtures/ONSPD_JUN_2023_UK_AB.csv")
        Postcode.create(postcode: "AB10AA", source: "os_places", results: ["Original Data"], retired: false)
      end

      it "does not touch the existing record" do
        OnsImportWorker.new.perform("ons/JUN_2023/AB.csv")
        expect(Postcode.count).to eq(5)
        record = Postcode.where(postcode: "AB10AA").first
        expect(record.retired).to be false
        expect(record.results).to eq(["Original Data"])
      end
    end

    context "with a file with an invalid doterm in it" do
      before do
        tempfile_from_fixture("#{Rails.root}/spec/fixtures/ONSPD_JUN_2023_UK_AB_broken.csv")
      end

      it "Imports records, marks doterm as Unknown if invalid, logs warning" do
        expect(s3_client).to receive(:get_object).once
        expect(Rails.logger).to receive(:warn)

        OnsImportWorker.new.perform("ons/JUN_2023/AB.csv")
        expect(Postcode.count).to eq(5)
        expect(Postcode.first.results.first["ONS"]["DOTERM"]).to eq("Unknown")
      end
    end

    context "with a key that points to a missing file" do
      before do
        allow(s3_client).to receive(:get_object).and_raise(Aws::Errors::ServiceError)
      end

      it "logs an error" do
        expect(s3_client).to receive(:get_object).once
        expect(GovukError).to receive(:notify)

        OnsImportWorker.new.perform("ons/JUN_2023/ABC.csv")
      end
    end
  end
end

def tempfile_from_fixture(file_path)
  tempfile = Tempfile.new("tmp/ONSPD.csv")
  content = File.open(file_path).read
  tempfile.write(content)
  tempfile.rewind
  allow(Tempfile).to receive(:new).and_return(tempfile)
end
