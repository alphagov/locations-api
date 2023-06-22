require "open-uri"
require "zip"

class OnsDownloadWorker < OnsBaseWorker
  # Example URL: https://www.arcgis.com/sharing/rest/content/items/a2f8c9c5778a452bbf640d98c166657c/data
  # retrieved by visiting https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD)
  # clicking on the first search result and then copying the link from the download button.

  DATAFILE_REGEX = /\AData\/multi_csv\/ONSPD_(.*)_UK_(.*).csv\z/

  def perform(url)
    # 1. Download File
    temp_zip_file = Tempfile.new("tmp/ONSPD.zip")
    IO.copy_stream(URI.parse(url).open, temp_zip_file.path)

    # 2. Unzip File/Data/multi_csv, and post to S3 bucket
    Zip::File.open(temp_zip_file.path) do |zip_file|
      zip_file.each do |entry|
        file_details = entry.name.match(DATAFILE_REGEX)
        next unless file_details

        begin
          s3_key_name = "ons/#{file_details.match(1)}/#{file_details.match(2)}.csv"
          content = entry.get_input_stream.read

          _response = s3_client.put_object(
            bucket: BUCKET_NAME,
            key: s3_key_name,
            body: content,
          )
          # TODO: check response.etag (if false, upload failed somehow?)
          # TODO: Kick off OnsImportWorker for the file
          # OnsImportWorker.new.perform_async(s3_key_name)
          puts "Added #{entry.name} to S3 bucket as #{s3_key_name}"
        rescue StandardError => e
          puts "Error extracting and uploading object #{e.message}"
        end
      end
    end
    # TODO: delete the zip file
  end
end
