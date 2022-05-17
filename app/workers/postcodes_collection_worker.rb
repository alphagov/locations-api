class PostcodesCollectionWorker
  include Sidekiq::Worker
  sidekiq_options queue: :queue_postcode, lock: :until_executed, lock_timeout: nil

  POSTCODES_PER_SECOND = 3

  def perform
    postcodes = Postcode.uncached do
      Postcode.all.sort_by(&:updated_at).pluck(:postcode).first(POSTCODES_PER_SECOND)
    end
    postcodes.each { |postcode| ProcessPostcodeWorker.perform_async(postcode) }
  end
end
