require "spec_helper"
require "rake"

RSpec.describe "postcode_info task" do
  let(:task) { Rake::Task["postcode_info"] }
  let(:postcode) { Postcode.create(postcode: "SW121AA") }

  context "with a missing postcode" do
    it "displays a not found message" do
      expected = <<~EXPECTED
        Postcode MI55 1NG not found
      EXPECTED

      task.reenable
      expect { task.invoke("MI55 1NG") }.to output(expected).to_stdout
    end
  end

  context "with a normal postcode" do
    it "displays relevant information" do
      expected = <<~EXPECTED
        Postcode SW12 1AA:
          Source: os_places
          Type: normal
          Last updated: #{postcode.updated_at}
      EXPECTED

      task.reenable
      expect { task.invoke("SW12 1AA") }.to output(expected).to_stdout
    end
  end

  context "with a Large User postcode" do
    let(:postcode) { Postcode.create(postcode: "LU530RR", source: "onspd", large_user_postcode: true) }

    it "displays relevant information" do
      expected = <<~EXPECTED
        Postcode LU53 0RR:
          Source: onspd
          Type: large user
          Last updated: #{postcode.updated_at}
      EXPECTED

      task.reenable
      expect { task.invoke("LU53 0RR") }.to output(expected).to_stdout
    end
  end

  context "with a retired postcode" do
    let(:postcode) do
      Postcode.create(
        postcode: "RE113RR",
        source: "onspd",
        retired: true,
        results: [{ "ONS" => { "DOTERM" => "April 2026" } }],
      )
    end

    it "displays relevant information and retirement date" do
      expected = <<~EXPECTED
        Postcode RE11 3RR:
          Source: onspd
          Type: normal
          Retired: April 2026
          Last updated: #{postcode.updated_at}
      EXPECTED

      task.reenable
      expect { task.invoke("RE11 3RR") }.to output(expected).to_stdout
    end
  end
end
