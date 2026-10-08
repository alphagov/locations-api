desc "Get info about a postcode"
task :postcode_info, [:postcode] => :environment do |_, args|
  # TODO: Test if the URL is valid before kicking off?
  postcode = Postcode.find_by(postcode: PostcodeHelper.normalise(args[:postcode]))

  if postcode
    puts("Postcode #{args[:postcode]}:")
    puts("  Source: #{postcode.source}")
    puts("  Type: #{postcode.large_user_postcode ? 'large user' : 'normal'}")
    puts("  Retired: #{doterm_date(postcode)}") if postcode.retired
    puts("  Last updated: #{postcode.updated_at}")
  else
    puts("Postcode #{args[:postcode]} not found")
  end
end

def doterm_date(retired_postcode)
  retired_postcode.results.first["ONS"]["DOTERM"]
end
