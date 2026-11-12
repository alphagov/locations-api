# Charts

Locations API has a Grafana dashboard ([specified here](https://github.com/alphagov/govuk-helm-charts/blob/main/charts/monitoring-config/rules/locations_api_alerts.yaml))

Grafana dashboards:
- [Production](https://grafana.eks.production.govuk.digital/d/ke7khl4/locations-api3a-oldest-os-places-api-postcode?from=now-90d&to=now&timezone=browser)
- [Staging](https://grafana.eks.staging.govuk.digital/d/ke7khl4/locations-api3a-oldest-os-places-api-postcode?from=now-90d&to=now&timezone=browser)
- [Integration](https://grafana.eks.integration.govuk.digital/d/ke7khl4/locations-api3a-oldest-os-places-api-postcode?from=now-90d&to=now&timezone=browser)

...show the value in days since the least recently updated postcode in the
database was refreshed. A high value may indicate that the refresh is happening
too slow, or there is a problem with one particular postcode. Note that this graph has a redline at 30 days - at this point an alert will also be firing in AlertManager. You can troubleshoot with the instructions here: [alerts](alerts.md)
