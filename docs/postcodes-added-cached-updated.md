# How postcodes are added, cached and updated

Locations API uses a PostgreSQL database to cache results from OS Places API; the provider where we get our postcode results from.

Read the original [architectural plan](https://docs.google.com/document/d/1p29g1SQgi2obQnPPsl9amx7xmrJonyH4tRbVMAhXy-A/edit#heading=h.1itfmfgfsgg7) for further details.

## How postcodes are added

When a request for a postcode is made to Locations API, Locations API checks its database.
If it doesn't have it, it will make a request to OS Places API, serve the response to the user, and save the result in the database.

We performed a one-off [import of all known postcodes](https://github.com/alphagov/locations-api/pull/71) to prime the cache before making Locations API available for Production use.

## How postcodes are updated

The results for a postcode can change over time, e.g. a building being renamed.

To minimise the risk of serving out of date responses, we keep postcode results up to date by spawning a `PostcodesCollectionWorker` sidekiq worker [every second](https://github.com/alphagov/locations-api/blob/b4575d39f33a9609245fd394a65f95296e332e11/config/sidekiq.yml#L12-L14). This worker grabs a few of the oldest records, and spawns a `ProcessPostcodeWorker` to update each one by performing a new fetch from OS Places API and overwriting the record.

We currently update [3 postcodes per second](https://github.com/alphagov/locations-api/blob/b4575d39f33a9609245fd394a65f95296e332e11/app/workers/postcodes_collection_worker.rb#L5), which would process 1.8 million postcodes in around 7 days. We have to take care to avoid straining the OS Places API, which has a rate limit of [600 requests per minute](https://osdatahub.os.uk/support/plans#:~:text=All%20our%20API%20data%20(OS%20OpenData%20and%20Premium)%20are%20subject%20to%20a%20600%20transactions%2Dper%2Dminute%20throttle%20for%20your%20live%20projects).
