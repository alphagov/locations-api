module V1
  class LocationsController < ApplicationController
    before_action :validate_postcode

    def index
      token_manager = OsPlacesApi::AccessTokenManager.new
      locations = OsPlacesApi::Client.new(token_manager).locations_for_postcode(params[:postcode])
      render json: locations
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
