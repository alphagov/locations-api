require "spec_helper"
require "rake"

RSpec.describe "lru_postcode task" do
  let(:task) { Rake::Task["lru_postcode"] }

  before do
    Postcode.create(postcode: "SW121AA")
    Postcode.create(postcode: "SW121AB", updated_at: Time.now - 1.day)
  end

  it "displays the least recently updated postcode" do
    p = Postcode.where(postcode: "SW121AB").first
    expected = <<~EXPECTED
      Postcode SW121AB, last refresh #{p.updated_at}
    EXPECTED

    task.reenable
    expect { task.invoke }.to output(expected).to_stdout
  end
end
