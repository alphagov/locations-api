desc "Update all "
task update_lup_flag: :environment do
  Postcode.onspd.find_in_batches(batch_size: 50) do |group|
    group.select { |r| r.results.first["ONS"]["TYPE"] == "L" }.each do |r|
      r.update(large_user_postcode: true)
    end
  end
end
