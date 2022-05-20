class ProcessPostcodeWorker
  include Sidekiq::Worker
  sidekiq_options queue: :update_postcode, lock: :until_and_while_executing, lock_timeout: nil

  def perform(postcode)
    token_manager = OsPlacesApi::AccessTokenManager.new
    OsPlacesApi::Client.new(token_manager).update_postcode(postcode)
  rescue OsPlacesApi::ClientError => e
    GovukError.notify(e)
  end
end
