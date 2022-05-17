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

      PostcodesCollectionWorker.new.perform(false)
    end

    it "sleeps for 1 second before spawning its replacement" do
      worker = PostcodesCollectionWorker.new
      allow(worker).to receive(:sleep) # stop it actually sleeping, for faster tests
      expect(worker).to receive(:sleep).with(1) # must be '1' for the 'POSTCODES_PER_SECOND' logic to work

      allow(PostcodesCollectionWorker).to receive(:perform_async)
      expect(PostcodesCollectionWorker).to receive(:perform_async)

      worker.perform(true)
    end

    it "cannot be invoked multiple times without the first invocation completing" do
      allow(ApplicationRecord).to receive(:with_advisory_lock)
      expect(ApplicationRecord).to receive(:with_advisory_lock)
      PostcodesCollectionWorker.new.perform(false)
    end
  end
end
