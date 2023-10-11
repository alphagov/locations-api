source "https://rubygems.org"

ruby "~> 3.2.0"

gem "rails", "7.1.0"

gem "aws-sdk-s3"
gem "bootsnap", require: false
gem "gds-api-adapters"
gem "govuk_app_config"
gem "govuk_sidekiq"
gem "httparty"
gem "pact", require: false
gem "pact_broker-client"
gem "pg"
gem "psych", "<6"
gem "rubyzip"
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
