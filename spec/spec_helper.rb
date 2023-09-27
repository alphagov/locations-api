ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
end

require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "webmock/rspec"

Rails.application.load_tasks

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
GovukTest.configure
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expose_dsl_globally = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
end
