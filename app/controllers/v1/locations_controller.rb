module V1
  class LocationsController < ApplicationController
    def index
      token_manager = OsPlacesApi::AccessTokenManager.new
      locations = OsPlacesApi::Client.new(token_manager).locations_for_postcode(params[:postcode])
      render json: locations
    end
  end
end
