class PostcodesCollectionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :queue_postcode, lock: :until_executed, lock_timeout: nil

  POSTCODES_PER_SECOND = ENV.fetch("OS_PLACES_API_POSTCODES_PER_SECOND", 3).to_i

  def perform
    postcodes = Postcode.uncached do
      Postcode.os_places.order("updated_at ASC").first(POSTCODES_PER_SECOND).pluck(:postcode)
    end
    postcodes.each { |postcode| ProcessPostcodeWorker.perform_async(postcode) }
  end
end
