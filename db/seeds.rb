# E1 8QS - the White Chapel building

Postcode.create(
  postcode: "E18QS",
  source: "os_places",
  retired: false,
  large_user_postcode: false,
  results: [
    {
      "DPA" => {
        "ADDRESS" => "WHITE CHAPEL BUILDING, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
        "LNG" => -0.0729671,
        "LAT" => 51.5144561,
        "LOCAL_CUSTODIAN_CODE" => 5900,
        "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "LONDON BOROUGH OF TOWER HAMLETS",
        "COUNTRY_CODE" => "E",
        "COUNTRY_CODE_DESCRIPTION" => "This record is within England",
      },
    },
  ],
)

# WV14 8TU - the classic split postcode example from https://democracyclub.org.uk/blog/2017/03/20/the-4314-times-when-postcodes-arent-good-enough/
# reduced to 3 addresses for simplicity

Postcode.create(
  postcode: "WV148TU",
  source: "os_places",
  retired: false,
  large_user_postcode: false,
  results: [
    {
      "DPA" => {
        "ADDRESS" => "1, BRIERLEY LANE, BILSTON, WV14 8TU",
        "LNG" => -2.0740947,
        "LAT" => 52.5499572,
        "LOCAL_CUSTODIAN_CODE" => 4615,
        "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "DUDLEY METROPOLITAN BOROUGH",
        "COUNTRY_CODE" => "E",
        "COUNTRY_CODE_DESCRIPTION" => "This record is within England",
      },
    },
    {
      "DPA" => {
        "ADDRESS" => "24, BRIERLEY LANE, BILSTON, WV14 8TU",
        "LNG" => -2.071536,
        "LAT" => 52.550167,
        "LOCAL_CUSTODIAN_CODE" => 4620,
        "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "SANDWELL METROPOLITAN BOROUGH",
        "COUNTRY_CODE" => "E",
        "COUNTRY_CODE_DESCRIPTION" => "This record is within England",
      },
    },
    {
      "DPA" => {
        "ADDRESS" => "42, BRIERLEY LANE, BILSTON, WV14 8TU",
        "LNG" => -2.0671866,
        "LAT" => 52.5508978,
        "LOCAL_CUSTODIAN_CODE" => 4635,
        "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "CITY OF WOLVERHAMPTON",
        "COUNTRY_CODE" => "E",
        "COUNTRY_CODE_DESCRIPTION" => "This record is within England",
      },
    },
  ],
)

# AL11HE - a large user postcode, not available in the OS places API so can't be used for local authority lookup but can
# be used for places-manager geocoding

Postcode.create(
  postcode: "AL11HE",
  source: "onspd",
  retired: false,
  large_user_postcode: true,
  results: [{ "ONS" => { "AVG_LNG" => "-0.340787", "AVG_LAT" => "51.748858", "TYPE" => "L", "DOTERM" => "" } }],
)

# AL11AA - as above, but also marked as retired

Postcode.create(
  postcode: "AL11AA",
  source: "onspd",
  retired: true,
  large_user_postcode: true,
  results: [{ "ONS" => { "AVG_LNG" => "-0.341314", "AVG_LAT" => "51.749090", "TYPE" => "L", "DOTERM" => "May 1994" } }],
)
