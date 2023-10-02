def mock_os_client_no_results
  os_client = double("os_client")
  allow(OsPlacesApi::Client).to receive(:new).and_return(os_client)
  allow(os_client).to receive(:retrieve_locations_for_postcode).and_raise(OsPlacesApi::NoResultsForPostcode)
  os_client
end

def mock_os_client_empty_results
  os_client = double("os_client")
  allow(OsPlacesApi::Client).to receive(:new).and_return(os_client)
  allow(os_client).to receive(:retrieve_locations_for_postcode).and_return(OsPlacesApi::LocationResults.new([]))
  os_client
end

def mock_os_client_good_results
  os_client = double("os_client")
  allow(OsPlacesApi::Client).to receive(:new).and_return(os_client)
  allow(os_client).to receive(:retrieve_locations_for_postcode).and_return(OsPlacesApi::LocationResults.new(os_places_api_results))
  os_client
end
