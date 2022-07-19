# frozen_string_literal: true

require 'fileutils'
require 'test_helper'

class GeneratorTest < Minitest::Test
  def setup
    @permanent_test_files = SafePath.new('permanent_test_files')
  end

  private

    def generate_fhir(source_file, table_mappings)
      generator = NdrFhir::Generator.new(@permanent_test_files.join(source_file),
                                         @permanent_test_files.join(table_mappings))
      generator.process
    end
end
