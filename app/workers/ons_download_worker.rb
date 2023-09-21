require "open-uri"
require "zip"

class OnsDownloadWorker < OnsBaseWorker
  DATAFILE_REGEX = /\AData\/multi_csv\/.*.csv\z/

  def perform(url)
    # 1. Download File
    temp_zip_file = Tempfile.new("ONSPD.zip")
    IO.copy_stream(URI.parse(url).open, temp_zip_file.path)

    # 2. Unzip File/Data/multi_csv, and post to S3 bucket
    Zip::File.open(temp_zip_file.path) do |zip_file|
      zip_file.each do |entry|
        file_details = entry.name.match(DATAFILE_REGEX)
        next unless file_details

        s3_client.put_object(
          bucket: BUCKET_NAME,
          key: entry.name,
          body: entry.get_input_stream.read,
        )

        OnsImportWorker.perform_async(entry.name)
        Rails.logger.info("ONS Download Worker: Added #{entry.name} to S3 bucket")
      end
    end
  rescue StandardError => e
    GovukError.notify("Problem downloading ONS file from #{url}: #{e.message}")
  end
end
