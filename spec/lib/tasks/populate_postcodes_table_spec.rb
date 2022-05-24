require "rake"
require "spec_helper"

Rails.application.load_tasks

RSpec.describe Tasks do
  describe "when running the task" do
    before do
      Postcode.destroy_all
    end

    let(:task) { Rake::Task["populate_postcodes_table"] }

    it "should add postcodes in the database" do
      expect(Postcode.count).to eq(0)

      task.reenable
      task.invoke("spec/lib/tasks/postcodes.csv")

      expect(Postcode.count).to eq(3)
    end

    it "shouldn't fail when a postcode already exists" do
      Postcode.create(postcode: "SE12TL")
      expect(Postcode.count).to eq(1)

      task.reenable
      task.invoke("spec/lib/tasks/postcodes.csv")

      expect(Postcode.count).to eq(3)
    end

    it "shouldn't overwrite existing postcode rows" do
      existing_result = '{ "foo": "bar" }'
      Postcode.create(postcode: "SE12TL", results: existing_result)
      expect(Postcode.count).to eq(1)

      task.reenable
      task.invoke("spec/lib/tasks/postcodes.csv")

      expect(Postcode.find_by(postcode: "SE12TL").results).to eq(existing_result)
    end
  end
end
