class OnspdLocationsPresenter < LocationsPresenter
  def to_hash
    {
      "source" => "Office of National Statistics",
      "average_latitude" => @postcode.results["ONS"]["AVG_LAT"].to_f,
      "average_longitude" => @postcode.results["ONS"]["AVG_LNG"].to_f,
      "results" => [],
      "warnings" => build_extended_information,
    }
  end

  def build_extended_information
    extended_information = { source: "ONS source updated infrequently" }

    if @postcode.retired?
      extended_information << { retired: "Postcode was retired in #{@postcode.results['ONS']['DOTERM']}" }
    end

    if @postcode.results["ONS"]["TYPE"] == "L"
      extended_information << { large: "Postcode is a large user postcode" }
    end

    extended_information
  end
end
