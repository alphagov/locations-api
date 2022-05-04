RSpec.describe PostcodesCollectionWorker do
  describe "#perform" do
    def perform
      described_class.new.perform
    end

    context "where there are postcodes to be refreshed" do
      before do
        allow(Postcode).to receive(:pluck).and_return(%w[E18QS E18QL])
      end

      it "creates a worker for each postcode" do
        worker = double("worker")
        allow(ProcessPostcodeWorker).to receive(:new).and_return(worker)
        expect(worker).to receive(:perform).with("E18QS")
        expect(worker).to receive(:perform).with("E18QL")

        expect(subject).to receive(:sleep).exactly(2).times

        subject.perform(run_continuously: false)
      end
    end
  end
end
