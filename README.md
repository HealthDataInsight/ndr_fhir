# NdrFhir [![Build Status](https://github.com/timgentry/ndr_fhir/workflows/Test/badge.svg)](https://github.com/timgentry/ndr_fhir/actions?query=workflow%3Atest)

Based on [Ollie Tulloch](https://github.com/ollietulloch)'s boilerplate MongoDB example, this generates [FHIR](https://fhir.apache.org) resources(s) using [NdrImport](https://github.com/PublicHealthEngland/ndr_import).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ndr_fhir', git: 'https://github.com/timgentry/ndr_fhir', branch: 'main'
```

And then execute:

    $ bundle install

## Usage

Below is an example that extracts data from a spreadsheet and transforms it into FHIR resources, defined by their "klass":

```ruby
require 'ndr_fhir'

source_file = SafePath.new(...).join('ABC_Collection-June-2020_03.xlsm')
table_mappings = SafePath.new(...).join('national_collection.yml')
generator = NdrFhir::Generator.new(source_file, table_mappings)
generator.process
```

See `test/ndr_fhir_test.rb` for a more complete working example.

More information on the workings of the mapper are available in the [wiki](https://github.com/PublicHealthEngland/ndr_import/wiki).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/timgentry/ndr_fhir. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/timgentry/ndr_fhir/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NdrFhir project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/timgentry/ndr_fhir/blob/main/CODE_OF_CONDUCT.md).
