require "prometheus_exporter"
require "prometheus_exporter/server"

module Collectors
  class GlobalPrometheusCollector < PrometheusExporter::Server::TypeCollector
    SECONDS_PER_DAY = 86_400

    def type
      "locations_api_global"
    end

    def metrics
      oldest_os_places_postcode = PrometheusExporter::Metric::Gauge.new("locations_api_oldest_os_places_postcode_age_days", "Days since oldest postcode was last updated via OS Places API (Expected in prod: ~7)")
      oldest_os_places_postcode.observe(get_oldest_postcode / SECONDS_PER_DAY)

      [oldest_os_places_postcode]
    end

  private

    def get_oldest_postcode
      # Cache metric to prevent needless expensive calls to the database
      Rails.cache.fetch("metrics:oldest_postcode", expires_in: 1.hour) do
        (Time.zone.now.to_i - Postcode.os_places.order(updated_at: :asc).first.updated_at.to_i)
      end
    end
  end
end
