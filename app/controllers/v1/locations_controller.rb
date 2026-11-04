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
        render_not_found("NOT_RECOGNISED")
      end
    end

  private

    def validate_postcode
      category = Postcodes::Utils.categorise(params[:postcode])
      return if category == Postcodes::Type::UK

      if category == Postcodes::Type::CROWN_DEPENDENCY
        return render_not_found("CROWN_DEPENDENCY")
      end

      render_invalid
    end

    def render_invalid
      render json: {
        errors: { "postcode": ["Invalid postcode provided"] },
        postcode_category: "INVALID",
      }, status: 400
    end

    def render_not_found(postcode_category)
      render json: {
        errors: { "postcode": ["No results found for given postcode"] },
        postcode_category:,
      }, status: 404
    end
  end
end
