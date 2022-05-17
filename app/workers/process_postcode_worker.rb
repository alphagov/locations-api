class ProcessPostcodeWorker
  include Sidekiq::Worker
  sidekiq_options queue: :update_postcode

  def perform(postcode)
    token_manager = OsPlacesApi::AccessTokenManager.new
    OsPlacesApi::Client.new(token_manager).locations_for_postcode(postcode, update: true)
  rescue OsPlacesApi::ClientError => e
    GovukError.notify(e)
  end
end
