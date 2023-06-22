def os_places_api_endpoint(postcode)
  "https://api.os.uk/search/places/v1/postcode?output_srs=WGS84&postcode=#{postcode}&dataset=DPA,LPI"
end

def mock_access_token_manager
  token_manager = double("token_manager")
  allow(OsPlacesApi::AccessTokenManager).to receive(:new).and_return(token_manager)
  allow(token_manager).to receive(:access_token).and_return("some token")
end

def stub_os_places_api_request(postcode, response, status: 200)
  stub_request(:get, os_places_api_endpoint(postcode))
    .to_return(status:, body: response.to_json)
end

def stub_os_places_api_request_invalid_response(postcode)
  stub_request(:get, os_places_api_endpoint(postcode))
    .to_return(status: 200, body: "foo")
end

def stub_os_places_api_request_good(postcode)
  stub_os_places_api_request(postcode, successful_response(postcode), status: 200)
end

def stub_os_places_api_request_empty_results(postcode)
  stub_os_places_api_request(postcode, empty_response(postcode), status: 200)
end

def stub_os_places_api_request_nil_results(postcode)
  stub_os_places_api_request(postcode, nil_response(postcode), status: 200)
end

def stub_os_places_api_request_filterable_results(postcode)
  stub_os_places_api_request(postcode, filterable_response(postcode), status: 200)
end

def successful_response(postcode)
  {
    "header": {
      "uri": os_places_api_endpoint(postcode),
      "query": "postcode=#{postcode}",
      "offset": 0,
      "totalresults": 1, # really 12, but we've omitted the other 11 in `results` above
      "format": "JSON",
      "dataset": "DPA,LPI",
      "lr": "EN,CY",
      "maxresults": 100,
      "epoch": "87",
      "output_srs": "WGS84",
    },
    "results": os_places_api_results,
  }
end

def os_places_api_results
  [
    {
      "DPA" => {
        "UPRN" => "6714278",
        "UDPRN" => "54673874",
        "ADDRESS" => "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
        "BUILDING_NUMBER" => "1",
        "THOROUGHFARE_NAME" => "WHITECHAPEL HIGH STREET",
        "POST_TOWN" => "LONDON",
        "POSTCODE" => "E1 8QS",
        "RPC" => "2",
        "X_COORDINATE" => 533_813.0,
        "Y_COORDINATE" => 181_262.0,
        "LNG" => -0.0729933,
        "LAT" => 51.5144547,
        "STATUS" => "APPROVED",
        "LOGICAL_STATUS_CODE" => "1",
        "CLASSIFICATION_CODE" => "CO01",
        "CLASSIFICATION_CODE_DESCRIPTION" => "Office / Work Studio",
        "LOCAL_CUSTODIAN_CODE" => 5900,
        "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "TOWER HAMLETS",
        "POSTAL_ADDRESS_CODE" => "D",
        "POSTAL_ADDRESS_CODE_DESCRIPTION" => "A record which is linked to PAF",
        "BLPU_STATE_CODE" => "1",
        "BLPU_STATE_CODE_DESCRIPTION" => "Under construction",
        "TOPOGRAPHY_LAYER_TOID" => "osgb1000006035651",
        "LAST_UPDATE_DATE" => "17/06/2017",
        "ENTRY_DATE" => "17/02/2017",
        "BLPU_STATE_DATE" => "17/02/2017",
        "LANGUAGE" => "EN",
        "MATCH" => 1.0,
        "MATCH_DESCRIPTION" => "EXACT",
      },
    },
    {
      "LPI" => {
        "UPRN" => "6714279",
        "ADDRESS" => "2, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
        "USRN" => "22701338",
        "LPI_KEY" => "5900L000449318",
        "PAO_START_NUMBER" => "2",
        "STREET_DESCRIPTION" => "WHITECHAPEL HIGH STREET",
        "TOWN_NAME" => "LONDON",
        "ADMINISTRATIVE_AREA" => "TOWER HAMLETS",
        "POSTCODE_LOCATOR" => "E1 8QS",
        "RPC" => "2",
        "X_COORDINATE" => 533_813.0,
        "Y_COORDINATE" => 181_262.0,
        "LNG" => -0.0729935,
        "LAT" => 51.5144545,
        "STATUS" => "APPROVED",
        "LOGICAL_STATUS_CODE" => "1",
        "CLASSIFICATION_CODE" => "CO01",
        "CLASSIFICATION_CODE_DESCRIPTION" => "Office / Work Studio",
        "LOCAL_CUSTODIAN_CODE" => 5900,
        "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "TOWER HAMLETS",
        "COUNTRY_CODE" => "E",
        "COUNTRY_CODE_DESCRIPTION" => "This record is within England",
        "POSTAL_ADDRESS_CODE" => "D",
        "POSTAL_ADDRESS_CODE_DESCRIPTION" => "A record which is linked to PAF",
        "BLPU_STATE_CODE" => "1",
        "BLPU_STATE_CODE_DESCRIPTION" => "Under construction",
        "TOPOGRAPHY_LAYER_TOID" => "osgb1000006035651",
        "LAST_UPDATE_DATE" => "17/06/2017",
        "ENTRY_DATE" => "17/02/2017",
        "BLPU_STATE_DATE" => "17/02/2017",
        "STREET_STATE_CODE" => "2",
        "STREET_STATE_CODE_DESCRIPTION" => "Open",
        "STREET_CLASSIFICATION_CODE" => "8",
        "STREET_CLASSIFICATION_CODE_DESCRIPTION" => "All vehicles",
        "LPI_LOGICAL_STATUS_CODE" => "1",
        "LPI_LOGICAL_STATUS_CODE_DESCRIPTION" => "APPROVED",
        "LANGUAGE" => "EN",
        "MATCH" => 1.0,
        "MATCH_DESCRIPTION" => "EXACT",
      },
    },
    {
      "DPA" => {
        "UPRN" => "10091989923",
        "UDPRN" => "54673879",
        "ADDRESS" => "10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
        "BUILDING_NUMBER" => "10",
        "THOROUGHFARE_NAME" => "WHITECHAPEL HIGH STREET",
        "POST_TOWN" => "LONDON",
        "POSTCODE" => "E1 8QS",
        "RPC" => "2",
        "X_COORDINATE" => 533_813.0,
        "Y_COORDINATE" => 181_262.0,
        "LNG" => -0.0729692,
        "LAT" => 51.5144785,
        "STATUS" => "APPROVED",
        "LOGICAL_STATUS_CODE" => "1",
        "CLASSIFICATION_CODE" => "CO01",
        "CLASSIFICATION_CODE_DESCRIPTION" => "Office / Work Studio",
        "LOCAL_CUSTODIAN_CODE" => 7655,
        "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "ORDNANCE SURVEY",
        "POSTAL_ADDRESS_CODE" => "E",
        "POSTAL_ADDRESS_CODE_DESCRIPTION" => "A record which is linked to PAF",
        "BLPU_STATE_CODE" => "1",
        "BLPU_STATE_CODE_DESCRIPTION" => "Under construction",
        "TOPOGRAPHY_LAYER_TOID" => "osgb1000006035651",
        "LAST_UPDATE_DATE" => "17/06/2017",
        "ENTRY_DATE" => "17/02/2017",
        "BLPU_STATE_DATE" => "17/02/2017",
        "LANGUAGE" => "EN",
        "MATCH" => 1.0,
        "MATCH_DESCRIPTION" => "EXACT",
      },
    },
    {
      "DPA" => {
        "UPRN" => "10091989923",
        "UDPRN" => "54673879",
        "ADDRESS" => "10, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
        "BUILDING_NUMBER" => "10",
        "THOROUGHFARE_NAME" => "WHITECHAPEL HIGH STREET",
        "POST_TOWN" => "LONDON",
        "POSTCODE" => "E1 8QS",
        "RPC" => "2",
        "X_COORDINATE" => 533_813.0,
        "Y_COORDINATE" => 181_262.0,
        "LNG" => -0.0729692,
        "LAT" => 51.5144785,
        "STATUS" => "APPROVED",
        "LOGICAL_STATUS_CODE" => "1",
        "CLASSIFICATION_CODE" => "CO01",
        "CLASSIFICATION_CODE_DESCRIPTION" => "Office / Work Studio",
        "LOCAL_CUSTODIAN_CODE" => 11,
        "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "HIGHWAYS ENGLAND",
        "POSTAL_ADDRESS_CODE" => "E",
        "POSTAL_ADDRESS_CODE_DESCRIPTION" => "A record which is linked to PAF",
        "BLPU_STATE_CODE" => "1",
        "BLPU_STATE_CODE_DESCRIPTION" => "Under construction",
        "TOPOGRAPHY_LAYER_TOID" => "osgb1000006035651",
        "LAST_UPDATE_DATE" => "17/06/2017",
        "ENTRY_DATE" => "17/02/2017",
        "BLPU_STATE_DATE" => "17/02/2017",
        "LANGUAGE" => "EN",
        "MATCH" => 1.0,
        "MATCH_DESCRIPTION" => "EXACT",
      },
    },
    # subsequent results omitted for brevity
  ]
end

def nil_response(postcode)
  base = successful_response(postcode)
  base[:header][:totalresults] = 0
  base[:results] = nil
  base
end

def empty_response(postcode)
  base = successful_response(postcode)
  base[:header][:totalresults] = 0
  base[:results] = []
  base
end

def filterable_response
  base = successful_response(postcode)
  base[:results] = os_places_api_results_with_filterable_locations,
                   base
end

def os_places_api_results_with_filterable_locations
  os_places_api_results.deep_dup.each do |location|
    location.values.first["LOCAL_CUSTODIAN_CODE_DESCRIPTION"] = "ORDNANCE SURVEY"
  end
end

def os_places_api_results_with_postal_address_code_n
  results = os_places_api_results
  results.first["DPA"]["POSTAL_ADDRESS_CODE"] = "N"
  results
end
