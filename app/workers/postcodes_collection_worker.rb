class PostcodesCollectionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :queue_postcode, lock: :until_executed, lock_timeout: nil

  POSTCODES_PER_SECOND = 3

  def perform
    postcodes = Postcode.uncached do
      Postcode.order("updated_at ASC").first(POSTCODES_PER_SECOND).pluck(:postcode)
    end
    postcodes.each { |postcode| ProcessPostcodeWorker.perform_async(postcode) }
  end
end
