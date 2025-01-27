class PostcodeManager
  def locations_for_postcode(postcode)
    normalised_postcode = PostcodeHelper.normalise(postcode)
    unless (record = Postcode.find_by(postcode: normalised_postcode))
      record = create_record_from_os_places_api(normalised_postcode)
    end

    LocationsPresenter.instance_for(record).to_hash
  end

  def update_postcode(postcode)
    normalised_postcode = PostcodeHelper.normalise(postcode)
    record = Postcode.find_by(postcode: normalised_postcode)
    location_results = location_results_from_os_places_api(normalised_postcode)
    raise OsPlacesApi::NoResultsForPostcode if location_results.empty?

    if record
      record.update(results: location_results.results, source: "os_places") && record.touch
    else
      Postcode.create!(postcode: normalised_postcode, source: "os_places", results: location_results.results)
    end
  rescue OsPlacesApi::NoResultsForPostcode
    if record
      record.source == "onspd" ? record.touch : record.destroy
    end
  end

private

  def create_record_from_os_places_api(normalised_postcode)
    location_results = location_results_from_os_places_api(normalised_postcode)
    raise OsPlacesApi::NoResultsForPostcode unless location_results.any_locations?

    Postcode.create_or_find_by!(postcode: normalised_postcode, source: "os_places", results: location_results.results)
  end

  def location_results_from_os_places_api(normalised_postcode)
    token_manager = OsPlacesApi::AccessTokenManager.new
    client = OsPlacesApi::Client.new(token_manager)
    # Can raise various errors, which we let flow to the controller
    client.retrieve_locations_for_postcode(normalised_postcode)
  end
end
