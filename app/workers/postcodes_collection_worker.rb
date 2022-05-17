class PostcodesCollectionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :queue_postcode

  POSTCODES_PER_SECOND = 3

  def perform(run_continuously = true) # rubocop:disable Style/OptionalBooleanParameter
    ApplicationRecord.with_advisory_lock("ProcessPostcodeWorker-single-worker", timeout_seconds: 0) do
      refresh_oldest_postcodes
    end
    process_next_batch if run_continuously
  end

private

  def refresh_oldest_postcodes
    postcodes = Postcode.uncached do
      Postcode.all.sort_by(&:updated_at).pluck(:postcode).first(POSTCODES_PER_SECOND)
    end
    postcodes.each { |postcode| ProcessPostcodeWorker.perform_async(postcode) }
  end

  def process_next_batch
    sleep 1
    PostcodesCollectionWorker.perform_async(true)
  end
end
