# frozen_string_literal: true

require 'ndr_import'
require 'ndr_import/universal_importer_helper'
require 'ndr_fhir/type_casting'
require 'ndr_fhir/generator/fhir_file_helper'
require 'pathname'

module NdrFhir
  # Reads file using NdrImport ETL logic and creates fhir file(s)
  class Generator
    include NdrImport::UniversalImporterHelper

    def initialize(filename, table_mappings, output_path = '')
      @filename = filename
      @table_mappings = YAML.load_file table_mappings
      @output_path = Pathname.new(output_path)
      @rawtext_column_names = {}
      @fhir_column_types = {}

      ensure_all_mappings_are_tables
    end

    def process
      mapped_hashes = {}
      rawtext_hashes = {}

      extract(@filename).each do |table, rows|
        table.transform(rows).each do |instance, fields, _index|
          klass = instance.split('#').first

          mapped_hashes[klass] ||= []
          mapped_hashes[klass] << fields.except(:rawtext)

          rawtext_hashes[klass] ||= []
          rawtext_hashes[klass] << fields[:rawtext]
        end
      end

      puts mapped_hashes.inspect
    end

    private

      def ensure_all_mappings_are_tables
        return if @table_mappings.all? { |table| table.is_a?(NdrImport::Table) }

        raise 'Mappings must be inherit from NdrImport::Table'
      end

      def unzip_path
        @unzip_path ||= SafePath.new('unzip_path')
      end

      def get_notifier(_value); end

      # TODO: Remove if unused during development
      def each_masked_mapping(table)
        masked_mappings = table.send(:masked_mappings)
        masked_mappings.each do |instance, columns|
          klass = instance.split('#').first

          yield klass, columns
        end
      end

      # TODO: Remove if unused during development
      def capture_all_rawtext_names(table)
        each_masked_mapping(table) do |klass, columns|
          @rawtext_column_names[klass] ||= Set.new

          columns.each do |column|
            rawtext_column_name = column[NdrImport::Mapper::Strings::RAWTEXT_NAME] ||
                                  column[NdrImport::Mapper::Strings::COLUMN]

            next if rawtext_column_name.nil?

            @rawtext_column_names[klass] << rawtext_column_name.downcase
          end
        end
      end
  end
end
