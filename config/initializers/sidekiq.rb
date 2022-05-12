Sidekiq.configure_server do |config|
  # Calls to Rails.logger in a sidekiq process will use Sidekiq's logger
  Rails.logger = Sidekiq::Logging.logger

  config.on(:startup) do
    ApplicationRecord.with_advisory_lock("PostcodesCollectionWorker-single-worker", timeout_seconds: 0) do
      Sidekiq::Queue.new("default").clear
      PostcodesCollectionWorker.new.perform(true)
    end
  end
end
