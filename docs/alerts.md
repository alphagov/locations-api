# Alerts

Locations API has one alert ([specified here](charts/monitoring-config/dashboards/locations-api-oldest-postcode.json))

When this alert is firing, it means that the least recently updated OS Places API
postcode has not been updated for more than 30 days (normally we'd expect this
value to be closer to 7 days).

If this fires, you can query which postcode is the least recently updated with:

`rake lru_postcode`

..and then try force-updating it with:

`rake update_postcode[<postcode from previous step>]`

If that command crashes, it may indicate (through the error) that the system has
somehow lost contact with the OS Places API. It may be a transient failure on
the Ordnance Survey side, an access key being revoked, or other failure.

If you need to speed up the rate at which Locations API queries OS Places API,
perhaps to catch up after an outage, you can do that by editing the value of
OS_PLACES_API_POSTCODES_PER_SECOND here:

https://github.com/alphagov/govuk-helm-charts/blob/2fd1fa32383694589670a389a9820235ca45ad6b/charts/app-config/values-production.yaml#L2179-L2180