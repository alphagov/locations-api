class ProcessPostcodeWorker
  include Sidekiq::Worker
  sidekiq_options queue: :update_postcode, lock: :until_and_while_executing, lock_timeout: nil, on_conflict: :log

  def perform(postcode)
    PostcodeManager.new.update_postcode(postcode)
    Rails.application.config.sidekiq_scheduler_backoff_service.record_success
  rescue OsPlacesApi::ClientError
    Rails.application.config.sidekiq_scheduler_backoff_service.record_failure
  end
end
