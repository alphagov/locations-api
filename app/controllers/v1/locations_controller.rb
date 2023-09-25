module V1
  class LocationsController < ApplicationController
    before_action :validate_postcode

    def index
      Sentry.set_tags postcode: PostcodeHelper.normalise(params[:postcode])

      begin
        render json: PostcodeManager.new.locations_for_postcode(params[:postcode])
      rescue OsPlacesApi::InvalidPostcodeProvided
        render json: { errors: { "postcode": ["Invalid postcode provided"] } }, status: 400
      rescue OsPlacesApi::NoResultsForPostcode
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
