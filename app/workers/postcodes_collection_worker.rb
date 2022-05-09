class PostcodesCollectionWorker
  include Sidekiq::Worker

  def perform(run_continuously: true)
    loop do
      ActiveRecord::Base.connection_pool.release_connection
      ActiveRecord::Base.connection_pool.with_connection do
        postcodes = Postcode.pluck(:postcode)
        postcodes.each do |postcode|
          ProcessPostcodeWorker.new.perform(postcode)
          sleep 1
        end
      end

      break unless run_continuously
    end
  end
end
