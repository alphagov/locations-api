RSpec.describe PostcodesCollectionWorker do
  describe "#perform" do
    context "where there are postcodes to be refreshed" do
      before do
        allow(Postcode).to receive(:pluck).and_return(%w[E18QS E18QL])
      end

      it "creates a worker for each postcode" do
        expect(ProcessPostcodeWorker).to receive(:perform_async).with("E18QS")
        expect(ProcessPostcodeWorker).to receive(:perform_async).with("E18QL")

        worker = PostcodesCollectionWorker.new
        allow(worker).to receive(:sleep)
        expect(worker).to receive(:sleep).exactly(2).times

        worker.perform(false)
      end
    end
  end
end
