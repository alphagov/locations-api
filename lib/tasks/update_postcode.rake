desc "Force an update of a postcode"
task :update_postcode, [:postcode] => :environment do |_, args|
  puts PostcodeManager.new.update_postcode(args[:postcode])
end
