desc "Run all linters"
task lint: :environment do
  sh "rubocop"
end
