class PostcodesCollectionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :queue_postcode, lock: :until_executed, lock_timeout: nil

  POSTCODES_PER_SECOND = ENV.fetch("OS_PLACES_API_POSTCODES_PER_SECOND", 3).to_i

  def perform
    postcodes.each { |postcode| ProcessPostcodeWorker.perform_async(postcode) }
  end

private

  def postcodes
    Postcode.uncached do
      Postcode.active.small.order("updated_at ASC").limit(POSTCODES_PER_SECOND).pluck(:postcode)
    end
  end
end
