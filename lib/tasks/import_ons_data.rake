require "csv"
require "json"

desc "Kick off import of ONS data, adding basic details for postcodes that aren't already in the system. Existing postcodes will not be touched."
task :import_ons_data, [:onspd_file_url] => :environment do |_, args|
  # TODO: Test if the URL is valid before kicking off?
  OnsDownloadWorker.new.perform_async(args[:onspd_file_url])
end
