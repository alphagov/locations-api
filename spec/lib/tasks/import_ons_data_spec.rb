require "spec_helper"
require "rake"

RSpec.describe "import_ons_data task" do
  let(:task) { Rake::Task["import_ons_data"] }

  context "when the import_ons_data task is invoked" do
    it "kicks off an OnsDownloadWorker job" do
      expect(OnsDownloadWorker).to receive(:perform_async).with("https://test.com/ONSPD_JUN_2023_UK.csv")

      task.reenable
      task.invoke("https://test.com/ONSPD_JUN_2023_UK.csv")
    end
  end
end
