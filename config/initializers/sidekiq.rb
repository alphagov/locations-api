require "sidekiq-unique-jobs"

Sidekiq.configure_server do |config|
  # Calls to Rails.logger in a sidekiq process will use Sidekiq's logger
  Rails.logger = Sidekiq::Logging.logger

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
