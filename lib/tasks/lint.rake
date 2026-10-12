desc "Run all linters"
task lint: :environment do
  # simplecov:disable
  sh "rubocop"
  # simplecov:enable
end
