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
      onspd_candidates = Postcode.onspd.active.order("updated_at ASC").select { |r| r.results.first["ONS"]["TYPE"] == "S" }.first(POSTCODES_PER_SECOND)
      os_places_candidates = Postcode.os_places.order("updated_at ASC").first(POSTCODES_PER_SECOND)
      (onspd_candidates + os_places_candidates).sort_by(&:updated_at).first(POSTCODES_PER_SECOND).pluck(:postcode)
    end
  end
end
