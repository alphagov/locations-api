require "sidekiq-unique-jobs"
require "sidekiq_scheduler_backoff_service"

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  config.logger.level = Rails.logger.level

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end

# Set backoff service to slow down schedule to once per 180 seconds if lots of errors
Rails.application.config.sidekiq_scheduler_backoff_service = SidekiqSchedulerBackoffService.new(
  name: "queue_oldest_postcodes_for_updating",
  min_interval: 1,
  max_interval: 180,
)
