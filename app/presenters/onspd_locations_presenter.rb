class OnspdLocationsPresenter < LocationsPresenter
  def to_hash
    {
      "source" => "Office of National Statistics",
      "average_longitude" => @postcode.results.first["ONS"]["AVG_LNG"].to_f,
      "average_latitude" => @postcode.results.first["ONS"]["AVG_LAT"].to_f,
      "results" => [],
      "extra_information" => extra_information,
    }
  end

  def extra_information
    extra_information = { source: "ONS source updated infrequently" }

    if @postcode.retired?
      extra_information.merge!(retired: "Postcode was retired in #{@postcode.results.first['ONS']['DOTERM']}")
    end

    if @postcode.results.first["ONS"]["TYPE"] == "L"
      extra_information.merge!(large: "Postcode is a large user postcode")
    end

    extra_information
  end
end
