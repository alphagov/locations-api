# Updating ONS Postcode Data

High-quality postcode data using in Locations API comes from the Ordnance Survey. But that dataset does not include all postcodes active (for instance, it excludes large user postcodes), nor does it include historical postcodes that people may still be using. To support this, we can import lower-quality postcode information from the Office for National Statistics Postcode Directory. The system will always use the high quality data where possible, but can use the low-quality data for geolocating in imminence datasets and lookups.

The Postcode Directory is updated a couple of times a year. An OnsUpdateCheckWorker checks the ONS rss feed once a day to see if a new version of the postcode data has been published, and if so starts an OnsDownloadWorker. This downloads the relevant file, splits out the multi-csv directory into an S3 bucket, and starts a single OnsImportWorker for each of the files.

## Manual Updates

In the event that a manual update is necessary, you can start an OnsDownloadWorker like this.

- Visit https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD) to see if there is a new version.
- Visit the page for the new version. There should be a Download link on the page. Copy the URL from that link.
- On the locations-api shell, run the rake task: `rails import_ons_data[<url you copied earlier>]`

