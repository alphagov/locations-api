module V1
  class LocationsController < ApplicationController
    before_action :validate_postcode

    def index
      Sentry.set_tags postcode: Postcodes::Utils.normalise(params[:postcode])

      begin
        render json: PostcodeManager.new.locations_for_postcode(params[:postcode])
      rescue OsPlacesApi::InvalidPostcodeProvided
        render_invalid
      rescue OsPlacesApi::NoResultsForPostcode
        render_not_found
      end
    end

  private

    def validate_postcode
      @req = PostcodeChecker.new(postcode: params[:postcode])

      unless @req.valid?(params[:postcode])
        render_invalid
      end
    end

    def render_invalid
      render json: { errors: { "postcode": ["Invalid postcode provided"] } }, status: 400
    end

    def render_not_found
      render json: { errors: { "postcode": ["No results found for given postcode"] } }, status: 404
    end
  end
end
