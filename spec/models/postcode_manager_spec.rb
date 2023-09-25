require "spec_helper"

RSpec.describe PostcodeManager, type: :model do
  let(:postcode) { "E1 8QS" }
  let(:normalised_postcode) { "E18QS" }
  let(:postcode_manager) { PostcodeManager.new }

  before do
    mock_access_token_manager
  end

  describe "#locations_for_postcode" do
    let(:address1) do
      {
        "ADDRESS" => "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
        "LAT" => 51.5144547,
        "LNG" => -0.0729933,
        "LOCAL_CUSTODIAN_CODE" => 5900,
        "UPRN" => "1",
      }
    end
    let(:address2) do
      {
        "ADDRESS" => "2, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
        "LAT" => 51.5144545,
        "LNG" => -0.0729935,
        "LOCAL_CUSTODIAN_CODE" => 5900,
        "UPRN" => "2",
      }
    end
    let(:api_locations) do
      [
        { "DPA" => address1 },
        { "DPA" => address2 },
      ]
    end
    let(:locations) do
      [address1, address2].map { |a| OsPlacesApi::LocationResults.new([]).build_location(a) }
    end
    let(:average_latitude) { 51.51446256666667 }
    let(:average_longitude) { -0.07298533333333333 }

    context "the postcode doesn't exist in the database" do
      before do
        Postcode.where(postcode: normalised_postcode).destroy_all
      end

      it "passes the query through to the api client" do
        mock_os_client = mock_os_client_good_results
        expect(mock_os_client).to receive(:retrieve_locations_for_postcode).with(normalised_postcode)

        postcode_manager.locations_for_postcode(postcode)
      end

      it "caches the response from a successful request" do
        expect(Postcode.where(postcode: normalised_postcode).count).to eq(0)
        mock_os_client_good_results
        postcode_manager.locations_for_postcode(postcode)
        expect(Postcode.where(postcode: normalised_postcode).count).to eq(1)
      end

      context "it doesn't have any locations in OS Places API" do
        it "raises an error" do
          mock_os_client_empty_results
          expect { postcode_manager.locations_for_postcode(postcode) }.to raise_error(OsPlacesApi::NoResultsForPostcode)
        end
      end
    end

    context "the postcode exists in the database" do
      it "returns the cached data" do
        Postcode.create(postcode:, source: "os_places", results: os_places_api_results)
        mock_os_client = mock_os_client_good_results
        expect(mock_os_client).not_to receive(:retrieve_locations_for_postcode)

        expect(postcode_manager.locations_for_postcode(postcode)).to eq(
          {
            "average_latitude" => average_latitude,
            "average_longitude" => average_longitude,
            "results" => locations.map(&:to_hash),
            "source" => "Ordnance Survey",
          },
        )
      end

      it "returns the cached data even if the postcode is structured differently in the database" do
        Postcode.create(postcode: normalised_postcode, results: os_places_api_results)
        mock_os_client = mock_os_client_good_results
        expect(mock_os_client).not_to receive(:retrieve_locations_for_postcode)

        expect(postcode_manager.locations_for_postcode(postcode)).to eq(
          {
            "average_latitude" => average_latitude,
            "average_longitude" => average_longitude,
            "results" => locations.map(&:to_hash),
            "source" => "Ordnance Survey",
          },
        )
      end
    end
  end

  describe "#update_postcode" do
    context "the postcode exists in the database" do
      before do
        Postcode.create!(postcode: normalised_postcode)
      end

      context "the api returns no locations" do
        before do
          mock_os_client_empty_results
        end

        it "deletes the postcode record" do
          expect(Postcode.where(postcode: normalised_postcode).count).to eq(1)
          postcode_manager.update_postcode(postcode)
          expect(Postcode.where(postcode: normalised_postcode).count).to eq(0)
        end
      end

      context "the api returns locations" do
        before do
          mock_os_client_good_results
        end

        it "updates the postcode record" do
          postcode_manager.update_postcode(postcode)
          expect(Postcode.where(postcode: normalised_postcode).first.results).to eq(os_places_api_results)
        end
      end
    end

    context "the postcode doesn't exist in the database" do
      before do
        Postcode.where(postcode: normalised_postcode).destroy_all
      end

      context "the api returns no locations" do
        before do
          mock_os_client_empty_results
        end

        it "does not create a postcode record" do
          postcode_manager.update_postcode(postcode)
          expect(Postcode.where(postcode: normalised_postcode).count).to eq(0)
        end
      end

      context "the api returns locations" do
        before do
          mock_os_client_good_results
        end

        it "creates a postcode record" do
          postcode_manager.update_postcode(postcode)
          expect(Postcode.where(postcode: normalised_postcode).count).to eq(1)
        end
      end
    end
  end
end
