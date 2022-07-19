# frozen_string_literal: true

require 'ndr_import'
require 'ndr_import/universal_importer_helper'
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

    def expand_dot_notation(mapped_hash)
      output_hash = {}
      mapped_hash.each do |key, value|
        pointer = output_hash

        sections = key.split('.')
        sections[0..-2].each do |section|
          # not the last part
          matchdata = section.match(/\A([^\[]*)(?:\[(\d+)\]\z)?/)
          section = matchdata[1]

          if matchdata[2].nil?
            # hash
            pointer[section] ||= {}
            pointer = pointer[section]
          else
            # array
            array_index = matchdata[2].to_i
            pointer[section] ||= []
            pointer[section][array_index] ||= {}
            pointer = pointer[section][array_index]
          end
        end

        pointer[sections.last] = value
      end
      output_hash
    end

    def process
      mapped_hashes = {}
      rawtext_hashes = {}

      extract(@filename).each do |table, rows|
        table.transform(rows).each do |instance, fields, _index|
          klass = instance.split('#').first

          if klass == 'FHIR::Patient'
            fields.delete('subject.reference')
          elsif fields['identifier[0].system'] == 'https://fhir.nhs.uk/Id/nhs-number'
            # NHS Number has mapped to a non Patient resource
            fields.delete('identifier[0].system')
            fields.delete('identifier[0].value')
          end

          mapped_fields = fields.except(:rawtext)
          mapped_hashes[klass] ||= []

          mapped_hashes[klass] << expand_dot_notation(mapped_fields)
        end
      end

      mapped_hashes
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
