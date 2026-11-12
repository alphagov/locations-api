desc "Get the least recently updated postcode that's eligible for refreshing"
task lru_postcode: :environment do
  postcode = Postcode.active.small.order("updated_at ASC").limit(1).first
  puts("Postcode #{postcode.postcode}, last refresh #{postcode.updated_at}")
end
