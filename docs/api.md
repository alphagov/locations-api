# Locations API's API

This is the primary interface for frontend apps to retrieve postcode-related data. It uses [OS Places API](https://developer.ordnancesurvey.co.uk/os-places-api) under the hood.

## Endpoints

- [`GET /v1/locations`](#get-v1locations)

### `GET /v1/locations`

Takes a `postcode` query string parameter (i.e. `/v1/locations?postcode=E18QS`). Returns JSON containing the average latitude and longitude for the postcode, and an array of addresses associated with the postcode.

Each address has the following properties:

- `postcode` (which will be the santised version of the `postcode` parameter given)
- `address` (full property address as a string)
- `latitude` (float)
- `longitude` (float)
- `local_custodian_code` (integer: the code identifying the local custodian responsible for maintaining this data)

Example response:

```json
{
  "average_latitude": 51.51446013333334,
  "average_longitude": -0.0730154,
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
