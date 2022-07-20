# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.6'

gem 'ndr_import', git: 'https://github.com/timgentry/ndr_import.git',
                  branch: 'feature/filename_column'

# Specify your gem's dependencies in ndr_fhir.gemspec
gemspec

gem 'minitest', '~> 5.0'
gem 'ndr_dev_support', '>= 3.1.3'
gem 'rake', '~> 13.0'
gem 'rubocop-minitest', require: false
gem 'simplecov'
gem 'fhir_models'
gem 'fhir_client'
group :test do
  gem 'mocha'
end