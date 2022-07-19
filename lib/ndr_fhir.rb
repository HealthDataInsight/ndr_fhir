# frozen_string_literal: true

require 'ndr_fhir/generator'
require 'ndr_fhir/version'

# This exposes the root folder for filesystem paths
module NdrFhir
  def self.root
    ::File.expand_path('..', __dir__)
  end
end
