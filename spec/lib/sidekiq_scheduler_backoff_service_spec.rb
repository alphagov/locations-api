require "spec_helper"

RSpec.describe SidekiqSchedulerBackoffService do
  let(:min_interval) { 2 }
  let(:max_interval) { 180 }
  let(:name) { :queue_oldest_postcodes_for_updating }
  subject { SidekiqSchedulerBackoffService.new(name:, min_interval:, max_interval:) }

  describe "#record_failure" do
    context "when the scheduler is going faster than maximum speed" do
      before do
        set_scheduled_interval(min_interval - 1)
      end

      it "sets the scheduler to maximum speed and reloads the schedule" do
        subject.record_failure
        expect(scheduled_interval).to eq("#{min_interval}s")
      end
    end

    context "when the scheduler is going faster than minimum speed" do
      before do
        set_scheduled_interval(max_interval / 2)
      end

      it "halves the scheduler speed and reloads the schedule" do
        subject.record_failure
        expect(scheduled_interval).to eq("#{max_interval}s")
      end
    end

    context "when the scheduler is going at minimum speed" do
      before do
        set_scheduled_interval(max_interval)
      end

      it "does nothing" do
        subject.record_failure
        expect(scheduled_interval).to eq("#{max_interval}s")
      end
    end

    context "when the scheduler is going slower than minimum speed" do
      before do
        set_scheduled_interval(max_interval * 2)
      end

      it "sets the scheduler to minimum speed and reloads the schedule" do
        subject.record_failure
        expect(scheduled_interval).to eq("#{max_interval}s")
      end
    end

    context "when the schedule is missing" do
      subject { SidekiqSchedulerBackoffService.new(name: "non-existing-queue", min_interval:, max_interval:) }

      it "records the problem to GovukError" do
        expect(GovukError).to receive(:notify)
        subject.record_failure
      end
    end
  end

  describe "#record_success" do
    context "when the scheduler is going faster than maximum speed" do
      before do
        set_scheduled_interval(min_interval - 1)
      end

      it "sets the scheduler to maximum speed and reloads the schedule" do
        subject.record_success
        expect(scheduled_interval).to eq("#{min_interval}s")
      end
    end

    context "when the scheduler is going at maximum speed" do
      before do
        set_scheduled_interval(min_interval)
      end

      it "does nothing" do
        subject.record_success
        expect(scheduled_interval).to eq("#{min_interval}s")
      end
    end

    context "when the scheduler is going slower than maximum speed" do
      before do
        set_scheduled_interval(min_interval * 4)
      end

      it "decremenincrements the scheduler speed by 1 second and reloads the schedule" do
        subject.record_success
        expect(scheduled_interval).to eq("#{(min_interval * 4) - 1}s")
      end
    end

    context "when the scheduler is going slower than minimum speed" do
      before do
        set_scheduled_interval(max_interval + 1)
      end

      it "sets the scheduler to minimum speed and reloads the schedule" do
        subject.record_success
        expect(scheduled_interval).to eq("#{max_interval}s")
      end
    end

    context "when the schedule is missing" do
      subject { SidekiqSchedulerBackoffService.new(name: "non-existing-queue", min_interval:, max_interval:) }

      it "records the problem to GovukError" do
        expect(GovukError).to receive(:notify)
        subject.record_success
      end
    end
  end
end

def set_scheduled_interval(interval)
  Sidekiq.set_schedule(name.to_s, { "every" => "#{interval}s", "class" => "PostcodesCollectionWorker" })
end

def scheduled_interval
  Sidekiq.get_schedule["queue_oldest_postcodes_for_updating"]["every"]
end
