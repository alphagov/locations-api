require "spec_helper"

RSpec.describe OsPlacesApi::Client do
  describe "#locations_for_postcode" do
    let(:client) do
      described_class.new(instance_double("AccessTokenManager", access_token: "some token"))
    end

    let(:postcode) { "E18QS" }

    it "should return results for the provided postcode" do
      results = [
        {
          "DPA" => {
            "UPRN" => "6714279",
            "UDPRN" => "54673874",
            "ADDRESS" => "1, WHITECHAPEL HIGH STREET, LONDON, E1 8QS",
            "BUILDING_NUMBER" => "1",
            "THOROUGHFARE_NAME" => "WHITECHAPEL HIGH STREET",
            "POST_TOWN" => "LONDON",
            "POSTCODE" => "E1 8QS",
            "RPC" => "2",
            "X_COORDINATE" => 533_813.0,
            "Y_COORDINATE" => 181_262.0,
            "STATUS" => "APPROVED",
            "LOGICAL_STATUS_CODE" => "1",
            "CLASSIFICATION_CODE" => "CO01",
            "CLASSIFICATION_CODE_DESCRIPTION" => "Office / Work Studio",
            "LOCAL_CUSTODIAN_CODE" => 5900,
            "LOCAL_CUSTODIAN_CODE_DESCRIPTION" => "TOWER HAMLETS",
            "POSTAL_ADDRESS_CODE" => "D",
            "POSTAL_ADDRESS_CODE_DESCRIPTION" => "A record which is linked to PAF",
            "BLPU_STATE_CODE" => "1",
            "BLPU_STATE_CODE_DESCRIPTION" => "Under construction",
            "TOPOGRAPHY_LAYER_TOID" => "osgb1000006035651",
            "LAST_UPDATE_DATE" => "17/06/2017",
            "ENTRY_DATE" => "17/02/2017",
            "BLPU_STATE_DATE" => "17/02/2017",
            "LANGUAGE" => "EN",
            "MATCH" => 1.0,
            "MATCH_DESCRIPTION" => "EXACT",
          },
        },
        # subsequent results omitted for brevity
      ]
      api_response = {
        "header": {
          "uri": "https://api.os.uk/search/places/v1/postcode?postcode=#{postcode}",
          "query": "postcode=#{postcode}",
          "offset": 0,
          "totalresults": 1, # really 12, but we've omitted the other 11 in `results` above
          "format": "JSON",
          "dataset": "DPA",
          "lr": "EN,CY",
          "maxresults": 100,
          "epoch": "87",
          "output_srs": "EPSG:27700",
        },
        "results": results,
      }
      stub_request(:get, "https://api.os.uk/search/places/v1/postcode?postcode=#{postcode}")
        .to_return(status: 200, body: api_response.to_json)

      expect(client.locations_for_postcode(postcode)).to eq(results)
    end
  end
end
