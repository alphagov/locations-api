source "https://rubygems.org"

gem "rails", "7.0.4.1"

gem "bootsnap", require: false
gem "gds-api-adapters"
gem "govuk_app_config"
gem "govuk_sidekiq"
gem "httparty"
gem "pact", require: false
gem "pact_broker-client"
gem "pg"
gem "sentry-sidekiq"
gem "sidekiq-scheduler"
gem "sidekiq-unique-jobs"

group :development do
  gem "listen"
end

group :test do
  gem "factory_bot_rails"
  gem "simplecov"
end

group :development, :test do
  gem "byebug"
  gem "climate_control"
  gem "govuk_test"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "webmock"
end
