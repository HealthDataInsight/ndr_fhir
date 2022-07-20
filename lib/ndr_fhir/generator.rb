# frozen_string_literal: true

require 'ndr_import'
require 'ndr_import/universal_importer_helper'
require 'pathname'
require 'fhir_models'
require 'fhir_client'

module NdrFhir
  # Reads file using NdrImport ETL logic and creates fhir file(s)
  class Generator
    include NdrImport::UniversalImporterHelper

    def initialize(url, filename, table_mappings, output_path = '')
      @filename = filename
      @table_mappings = YAML.load_file table_mappings
      @output_path = Pathname.new(output_path)
      @rawtext_column_names = {}
      @fhir_column_types = {}

      ensure_all_mappings_are_tables
      @url = url
    end

    def process
      client = initialize_fhir_client

      extract(@filename).each do |table, rows|
        rows.each do |row|
          fhir_models = []

          table.transform([row]).each do |instance, fields, _index|
            next if instance == 'Hash' # TODO: temporary until all fields mapped

            row_data    = expand_dot_notation(fields)
            fhir_models << fhir_model(row_data, instance)
          end
          # we'll have all the fhir_models for this row of data
          NdrFhir::Send.new(client, fhir_models).call
        end
      end
    end

    private

    def initialize_fhir_client
      FHIR::Client.new(@url)
      # TODO: looks like two ways to use client. if using client transactions we don't need this
      # client = FHIR::Client.new(url)
      # FHIR::Model.client = client
    end

    # TODO: if we have correct mapped fields structure, we should be able let NdrImport 
    #       automatically do the work of klass.new
    def fhir_model(fields, klass)
      FHIR.from_contents(fields.merge('resourceType' => klass).to_json)
    end

    def expand_dot_notation(mapped_hash)
      output_hash = {}
      mapped_hash.except(:rawtext).each do |key, value|
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

    def ensure_all_mappings_are_tables
      return if @table_mappings.all? { |table| table.is_a?(NdrImport::Table) }

      raise 'Mappings must be inherit from NdrImport::Table'
    end

    def unzip_path
      @unzip_path ||= SafePath.new('unzip_path')
    end

    def get_notifier(_value); end
  end
end
