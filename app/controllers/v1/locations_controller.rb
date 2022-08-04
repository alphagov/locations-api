module V1
  class LocationsController < ApplicationController
    before_action :validate_postcode

    def index
      token_manager = OsPlacesApi::AccessTokenManager.new
      begin
        locations = OsPlacesApi::Client.new(token_manager).locations_for_postcode(params[:postcode])
        render json: locations
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
