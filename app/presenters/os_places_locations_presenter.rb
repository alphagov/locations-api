class OsPlacesLocationsPresenter < LocationsPresenter
  def to_hash
    location_results = OsPlacesApi::LocationResults.new(@postcode.results)
    locations = location_results.unfiltered_locations

    {
      "source" => "Ordnance Survey",
      "average_longitude" => locations.sum(0.0, &:longitude) / locations.size.to_f,
      "average_latitude" => locations.sum(0.0, &:latitude) / locations.size.to_f,
      "results" => location_results.filtered_locations.map(&:to_hash),
    }
  end
end
