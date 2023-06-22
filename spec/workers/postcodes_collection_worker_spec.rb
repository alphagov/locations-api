require "spec_helper"

RSpec.describe PostcodesCollectionWorker do
  describe "#perform" do
    before do
      Postcode.destroy_all
      Postcode.create(postcode: "E18QS", updated_at: 2.days.ago, results: "{}")
      Postcode.create(postcode: "E18QL", updated_at: 1.day.ago, results: "{}")
      Postcode.create(postcode: "E18QT", updated_at: Time.now, results: "{}")
    end

    it "creates a ProcessPostcodeWorker for only the oldest postcodes" do
      stub_const("PostcodesCollectionWorker::POSTCODES_PER_SECOND", 2)
      expect(ProcessPostcodeWorker).to receive(:perform_async).with("E18QS").ordered
      expect(ProcessPostcodeWorker).to receive(:perform_async).with("E18QL").ordered
      expect(ProcessPostcodeWorker).not_to receive(:perform_async).with("E18QT")

      PostcodesCollectionWorker.new.perform
    end
  end
end
