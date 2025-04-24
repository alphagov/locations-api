require "spec_helper"
require "rake"

RSpec.describe "update_lup_flag task" do
  let(:task) { Rake::Task["update_lup_flag"] }

  context "when the update_lup_flag task is invoked" do
    before do
      Postcode.create(postcode: "E12AA", source: "onspd", updated_at: 3.days.ago, results: [{ "ONS" => { "TYPE" => "L" } }])
      Postcode.create(postcode: "E13AA", source: "onspd", updated_at: 3.days.ago, results: [{ "ONS" => { "TYPE" => "S" } }])
    end

    it "sets the large_user_postcode flag true for LUP postcodes, but not for small ones" do
      task.reenable
      task.invoke

      expect(Postcode.onspd.where(postcode: "E12AA", large_user_postcode: true).count).to eq(1)
      expect(Postcode.onspd.where(postcode: "E13AA", large_user_postcode: false).count).to eq(1)
    end
  end
end
