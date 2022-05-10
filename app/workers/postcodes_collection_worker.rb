class PostcodesCollectionWorker
  include Sidekiq::Worker

  def perform(run_continuously = true) # rubocop:disable Style/OptionalBooleanParameter
    postcodes = Postcode.pluck(:postcode)
    postcodes.each do |postcode|
      ProcessPostcodeWorker.perform_async(postcode)
      sleep 1
    end
    PostcodesCollectionWorker.perform_async(run_continuously) if run_continuously
  end
end
