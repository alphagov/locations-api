module V1
  class LocationsController < ApplicationController
    before_action :validate_postcode

    def index
      Sentry.set_tags postcode: PostcodeHelper.normalise(params[:postcode])

      token_manager = OsPlacesApi::AccessTokenManager.new
      begin
        locations = OsPlacesApi::Client.new(token_manager).locations_for_postcode(params[:postcode])
        render json: locations
      rescue OsPlacesApi::NoResultsForPostcode => e
        Sentry.capture_exception(e) # Ensure that this exception is still reported
        render json: { errors: { "postcode": ["No results found for given postcode"] } }, status: 404
      end
    end

  private

    def validate_postcode
      @req = PostcodeChecker.new(postcode: params[:postcode])

      unless @req.valid?(params[:postcode])
        render json: { errors: @req.errors }, status: 400
      end
    end
  end
end
