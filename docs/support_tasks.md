# Support Tasks

## Get basic information about a postcode

You can get basic information about a postcode (whether it's present in the database, the source of the data, whether it's a large user postcode, last updated, and whether it's retired) with:

`rake postcode_info[SW1A 1AA]`

(It will accept postcode with or without the space between in-code and out-code)

## Find the least recently updated postcode

This will show you the least recently updated postcode in the database from those that are eligible to be updated (OS Places postcodes and ONSPD postcodes that are neither Large or Retired)

`rake lru_postcode`
