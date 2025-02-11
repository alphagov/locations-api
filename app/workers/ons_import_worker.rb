require "csv"

class OnsImportWorker < OnsBaseWorker
  def perform(s3_key_name)
    temp_csv_file = Tempfile.new("ONSPD.csv")

    s3_client.get_object(
      response_target: temp_csv_file.path,
      bucket: BUCKET_NAME,
      key: s3_key_name,
    )

    CSV.foreach(temp_csv_file.path, headers: true) do |row|
      postcode = PostcodeHelper.normalise(row["pcds"])
      next if Postcode.os_places.where(postcode:).any?

      termination_date = parse_termination_date(row["doterm"])
      large_user_postcode = (row["usertype"] != "0")

      results = [
        {
          "ONS" => {
            "AVG_LNG" => row["long"],
            "AVG_LAT" => row["lat"],
            "TYPE" => large_user_postcode ? "L" : "S",
            "DOTERM" => termination_date,
          },
        },
      ]

      retired = termination_date.blank? ? false : true

      existing_record = Postcode.onspd.find_by(postcode:)
      if existing_record
        existing_record.update(retired:, large_user_postcode:, results:)
      else
        Postcode.create(postcode:, source: "onspd", retired:, large_user_postcode:, results:)
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
