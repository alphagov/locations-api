require "aws-sdk-s3"

class OnsBaseWorker
  include Sidekiq::Worker
  sidekiq_options queue: :queue_ons, lock: :until_executed, lock_timeout: nil

  BUCKET_NAME = "govuk-#{ENV['GOVUK_ENVIRONMENT']}-locations-api-import-csvs".freeze

  def s3_client
    @s3_client ||= Aws::S3::Client.new(region: "eu-west-1")
  end
end
