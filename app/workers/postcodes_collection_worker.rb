class PostcodesCollectionWorker
  include Sidekiq::Worker

  def perform(run_continuously = true) # rubocop:disable Style/OptionalBooleanParameter
    ApplicationRecord.with_advisory_lock("ProcessPostcodeWorker-single-worker", timeout_seconds: 0) do
      loop do
        refresh_all_postcodes
        break unless run_continuously
      end
    end
  end

private

  def refresh_all_postcodes
    postcodes = Postcode.uncached { Postcode.pluck(:postcode) }
    postcodes.each do |postcode|
      ProcessPostcodeWorker.perform_async(postcode)
      sleep 1
    end
    sleep 10 if postcodes.count.zero?
  end
end
