require "spec_helper"
require "rake"

RSpec.describe "update_postcode task" do
  let(:task) { Rake::Task["update_postcode"] }

  before do
    mock_access_token_manager
  end

  it "calls PostcodeManager#update_postcode with the passed argument and displays the output" do
    mock_os_client = mock_os_client_good_results
    expect(mock_os_client).to receive(:retrieve_locations_for_postcode).with("SW121AA")

    task.reenable
    expect { task.invoke("SW12 1AA") }.to output("Postcode created from OS Places API\n").to_stdout
  end
end
