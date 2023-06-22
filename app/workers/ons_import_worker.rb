class OnsImportWorker < OnsBaseWorker
  def perform(s3_key_name)
    temp_csv_file = Tempfile.new("tmp/ONSPD.csv")

    s3_client.get_object(
      response_target: temp_csv_file.path,
      bucket: BUCKET_NAME,
      key: s3_key_name,
    )

    CSV.foreach(temp_csv_file.path, headers: true) do |row|
      postcode = PostcodeHelper.normalise(row["pcds"])
      next if Postcode.where(postcode:).count.positive?

      termination_date = parse_termination_date(row["doterm"])
      results = [
        {
          "ONS" => {
            "AVG_LNG" => row["long"],
            "AVG_LAT" => row["lat"],
            "TYPE" => row["usertype"] == "0" ? "S" : "L",
            "DOTERM" => termination_date,
          },
        },
      ]

      retired = termination_date.blank? ? false : true

      Postcode.create(postcode:, source: "onspd", retired:, results:)
    end
  rescue StandardError => e
    puts "Error getting object: #{e.message}"
  end

  def parse_termination_date(doterm_string)
    doterm_string.blank? ? "" : Date.strptime(doterm_string).strftime("%B %Y")
  rescue Date::Error
    "Unknown"
  end
end
