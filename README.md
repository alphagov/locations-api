# Locations API

Acts as an interface between GOV.UK's frontend applications and external APIs involved in location based services (e.g. postcode lookups).

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

### Running the test suite

To run all tests and linters:

```
bundle exec rake
```

To run all tests:

```
bundle exec rake test
```

To run a single rspec file:

```
bundle exec rspec spec/my_spec.rb
```

To run all linters:

```
bundle exec rake lint
```

### Further documentation

* [How postcodes are added, cached and updated](docs/postcodes-added-cached-updated.md)
* [OS Places API](docs/os-places-api.md)

## Licence

[MIT LICENCE](LICENCE).
