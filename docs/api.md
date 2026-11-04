# Locations API's API

This is the primary interface for frontend apps to retrieve postcode-related data. It uses [OS Places API](https://developer.ordnancesurvey.co.uk/os-places-api) under the hood.

## Endpoints

- [`GET /v1/locations`](#get-v1locations)

### `GET /v1/locations`

Takes a `postcode` query string parameter (i.e. `/v1/locations?postcode=E18QS`). On success returns a 200 code and JSON containing the source, average latitude and longitude for the postcode, a postcode cateogry, and an array of addresses associated with the postcode. Optionally there may be extra information.

`postcode_category` will be one of:

- `RECOGNISED`: This postcode is in the OS Places Api database.
- `NOT_RECOGNISED`: Only returned for 404 responses. The postcode is a potentially valid UK postcode, but is not in the OS Places API database or in the ONSPD postcode file. This may mean it's an extremely new postcode, or just a mistyped postcode
- `CROWN_DEPENDENCY`: Only returned for 404 responses. The postcode is for Jersey, Guernsey, or the Isle of Man
- `INVALID`: Only returned for 400 responses. The postcode could not be a valid UK postcode

If addresses are returned, each address has the following properties:

- `postcode` (which will be the santised version of the `postcode` parameter given)
- `address` (full property address as a string)
- `latitude` (float)
- `longitude` (float)
- `local_custodian_code` (integer: the code identifying the local custodian responsible for maintaining this data)

Error cases:
- Returns 400 if the postcode is missing or malformed (ie could not possibly be a valid UK postcode)
- Returns 404 if no results were found (for various reasons)

Error cases will also return a JSON with errors, and 404 returns may also contain a postcode_category code for the postcode (which the api client may wish to use to return a more specific error to the end user)

#### Example 200 response (to `/v1/locations?postcode=E18QS`):

```json
{
  "source": "Ordnance Survey",
  "average_latitude": 51.51446013333334,
  "average_longitude": -0.0730154,
  "postcode_category": "RECOGNISED",
  "results": [
    {
      "postcode": "E1 8QS",
      "address": "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144426,
      "longitude": -0.0729707,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "5, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144844,
      "longitude": -0.0733293,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "THE SHIPOWNERS CLUB, SUITE 1, 10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144547,
      "longitude": -0.0729933,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "COMEON LONDON, SUITE 1A, 10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144547,
      "longitude": -0.0729933,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "PERKINS & WILL, SUITE 2, 10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144547,
      "longitude": -0.0729933,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "REDDIE & GROSE LLP, SUITE 3, 10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144785,
      "longitude": -0.0729692,
      "local_custodian_code": 7655
    },
    {
      "postcode": "E1 8QS",
      "address": "REDDIE & GROSE LLP, SUITE 4, 10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144547,
      "longitude": -0.0729933,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "GOVERNMENT DIGITAL SERVICES, SUITE 6-7, 10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144547,
      "longitude": -0.0729933,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "DERWENT LONDON, 10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144547,
      "longitude": -0.0729933,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "ELEMENTA CONSULTING, 10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144785,
      "longitude": -0.0729692,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "WILMINGTON PLC, 10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144547,
      "longitude": -0.0729933,
      "local_custodian_code": 5900
    },
    {
      "postcode": "E1 8QS",
      "address": "LOVE CORN, 15, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
      "latitude": 51.5144547,
      "longitude": -0.0729933,
      "local_custodian_code": 5900
    }
  ]
}
```

This is a detailed postcode.

#### Example 200 response (to `/v1/locations?postcode=AL11AA`):

```json
{
  "source": "Office of National Statistics",
  "average_latitude": 51.749090,
  "average_longitude": -0.341314,
  "postcode_category": "RECOGNISED",
  "results": [],
  "extra_information": {
    "source": "ONS source updated infrequently",
    "retired": "Postcode was retired in May 1994",
    "large": "Postcode is a large user postcode"
  }
```

This is a retired postcode, for which we don't have results, but we do have a lat/long.

#### Example 400 response (to `/v1/locations?postcode=My+House+Address`):

```json
{
  "errors": {
    "postcode": [ "Invalid postcode provided" ]
  },
  "postcode_category": "INVALID",
}
```

This is a completely invalid postcode.

#### Example 404 response (to `/v1/locations?postcode=JE1+1AA`):

```json
{
  "errors": {
    "postcode": [ "No results found for given postcode" ],
  },
  "postcode_category": "CROWN_DEPENDENCY",
}
```

This is a valid Jersey postcode, but we do not support lookups in Jersey.

#### Example 404 response (to `/v1/locations?postcode=SW1A+2ZZ`):

```json
{
  "errors": {
    "postcode": [ "No results found for given postcode" ],
  },
  "postcode_category": "NOT_RECOGNISED",
}
```

This is a postcode that _might_ be a UK postcode (it fits the pattern), but isn't in our database.
