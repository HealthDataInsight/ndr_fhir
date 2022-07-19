# frozen_string_literal: true

require 'fileutils'
require 'test_helper'

class GeneratorTest < Minitest::Test
  def setup
    @permanent_test_files = SafePath.new('permanent_test_files')
  end

  def test_should_process_file
    # mapped_hashes = generate_fhir('fake_dids_100.csv', 'dids_mapping.yml')
    # TODO: Add tests here
  end

  private

    def generate_fhir(source_file, table_mappings)
      generator = NdrFhir::Generator.new(@permanent_test_files.join(source_file),
                                         @permanent_test_files.join(table_mappings))
      generator.process
    end
end
