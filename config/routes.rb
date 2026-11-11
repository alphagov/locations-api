Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
    GovukHealthcheck::SidekiqRedis,
  )

  namespace :v1 do
    get "/locations", to: "locations#index"
  end

  require "sidekiq/web"
  require "sidekiq-scheduler/web"

  mount Sidekiq::Web, at: "/sidekiq"
end
