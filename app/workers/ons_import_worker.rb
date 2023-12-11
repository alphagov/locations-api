class OnsImportWorker < OnsBaseWorker
  def perform(s3_key_name)
    temp_csv_file = Tempfile.new("ONSPD.csv")

    s3_client.get_object(
      response_target: temp_csv_file.path,
      bucket: BUCKET_NAME,
      key: s3_key_name,
    )

    CSV.foreach(temp_csv_file.path, headers: true) do |row|
      puts("Importing G82 3PW") if row["pcds"] == "G82 3PW"
      postcode = PostcodeHelper.normalise(row["pcds"])

      puts("Skipping #{postcode}") if Postcode.os_places.where(postcode:).any? && row["pcds"] == "G82 3PW"
      next if Postcode.os_places.where(postcode:).any?

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

      existing_record = Postcode.onspd.find_by(postcode:)
      if existing_record
        existing_record.update(retired:, results:)
        puts("Updating existing record for G82 3PW") if row["pcds"] == "G82 3PW"
      else
        record = Postcode.create(postcode:, source: "onspd", retired:, results:)
        puts("Creating new record for G82 3PW") if row["pcds"] == "G82 3PW"
        puts("Is record valid for G82 3PW? #{record.valid?}") if row["pcds"] == "G82 3PW"
      end
    end
  rescue StandardError => e
    GovukError.notify("ONS Import Worker import problem: #{e.message}")
  end

  def parse_termination_date(doterm_string)
    doterm_string.blank? ? "" : Time.strptime(doterm_string, "%Y%m").strftime("%B %Y")
  rescue ArgumentError
    Rails.logger.warn("ONS Import Worker found unparseable doterm: #{doterm_string}")
    "Unknown"
  end
end
