class ProcessPostcodeWorker
  include Sidekiq::Worker

  def perform(postcode)
    token_manager = OsPlacesApi::AccessTokenManager.new
    OsPlacesApi::Client.new(token_manager).locations_for_postcode(postcode, update: true)
  end
end
