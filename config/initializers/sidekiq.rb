Sidekiq.configure_server do |config|
  # Calls to Rails.logger in a sidekiq process will use Sidekiq's logger
  Rails.logger = Sidekiq::Logging.logger

  config.on(:startup) do
    PostcodesCollectionWorker.perform_async(true)
  end
end
