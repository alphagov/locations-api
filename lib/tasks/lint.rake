desc "Run all linters"
task lint: :environment do
  # :nocov:
  sh "rubocop"
  # :nocov:
end
