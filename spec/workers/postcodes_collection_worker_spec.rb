require "spec_helper"

RSpec.describe PostcodesCollectionWorker do
  describe "#perform" do
    before do
      Postcode.destroy_all
      Postcode.create(postcode: "E18QS", updated_at: 2.days.ago, results: "{}")
      Postcode.create(postcode: "E18QL", updated_at: 1.day.ago, results: "{}")
      Postcode.create(postcode: "E18QT", updated_at: Time.now, results: "{}")
      stub_const("PostcodesCollectionWorker::POSTCODES_PER_SECOND", 2)
    end

    it "creates a ProcessPostcodeWorker for only the oldest postcodes" do
      expect(ProcessPostcodeWorker).to receive(:perform_async).with("E18QS").ordered
      expect(ProcessPostcodeWorker).to receive(:perform_async).with("E18QL").ordered
      expect(ProcessPostcodeWorker).not_to receive(:perform_async).with("E18QT")

      PostcodesCollectionWorker.new.perform
    end

    context "when an ONSPD small active postcode is older than the oldest OS Places postcode" do
      before do
        Postcode.create(postcode: "E12AA", source: "onspd", updated_at: 3.days.ago)
      end

      it "adds the onspd postcode to the update checker" do
        expect(ProcessPostcodeWorker).to receive(:perform_async).with("E12AA").ordered
        expect(ProcessPostcodeWorker).to receive(:perform_async).with("E18QS").ordered
        expect(ProcessPostcodeWorker).not_to receive(:perform_async).with("E18QL")
        expect(ProcessPostcodeWorker).not_to receive(:perform_async).with("E18QT")

        PostcodesCollectionWorker.new.perform
      end
    end

    context "when an ONSPD small retired postcode is older than the oldest OS Places postcode" do
      before do
        Postcode.create(postcode: "E12AA", source: "onspd", updated_at: 3.days.ago, retired: true)
      end

      it "does not attempt to update the ONSPD postcode" do
        expect(ProcessPostcodeWorker).not_to receive(:perform_async).with("E12AA")

        PostcodesCollectionWorker.new.perform
      end
    end

    context "when an ONSPD large active postcode is older than the oldest OS Places postcode" do
      before do
        Postcode.create(postcode: "E12AA", source: "onspd", updated_at: 3.days.ago, large_user_postcode: true)
      end

      it "does not attempt to update the ONSPD postcode" do
        expect(ProcessPostcodeWorker).not_to receive(:perform_async).with("E12AA")

        PostcodesCollectionWorker.new.perform
      end
    end
  end
end
