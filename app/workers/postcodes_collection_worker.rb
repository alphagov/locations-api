class PostcodesCollectionWorker
  include Sidekiq::Worker

  def perform(run_continuously: true)
    loop do
      postcodes = Postcode.pluck(:postcode)

      postcodes.each do |postcode|
        ProcessPostcodeWorker.new.perform(postcode)
        sleep 1
      end

      break unless run_continuously
    end
  end
end
