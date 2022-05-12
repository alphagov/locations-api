require "csv"
require "json"

desc "add postcodes to Locations API via CSV file. Existing postcodes will be skipped over."
task :populate_postcodes_table, [:path_to_csv] => :environment do |_, args|
  puts "Start processing postcodes..."
  csv = CSV.new(File.read(args[:path_to_csv]))

  count = 0
  while (postcode = csv.shift)
    begin
      Postcode.create!(postcode: postcode, results: "{}")
      count += 1
      puts "#{count} postcodes processed"
    rescue ActiveRecord::RecordInvalid
      nil
    end
  end
end
