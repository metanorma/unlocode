# frozen_string_literal: true

require 'json'
require_relative 'entry'

module Unlocode
  # Parses a UN/LOCODE JSON-LD vocabulary file into {Entry} instances.
  #
  # The UNCEFACT vocabulary (`vocab/unlocode.jsonld`) is a single JSON-LD
  # document whose `@graph` array contains one `unlcdv:UNLOCODE` resource per
  # LOCODE. Each resource uses these wire names:
  #
  #   @id                       → "unlcd:CNSHA"
  #   @type                     → "unlcdv:UNLOCODE"
  #   rdf:value                 → "CNSHA"                         (5-char LOCODE)
  #   rdfs:label                → {"@language":"en","@value":..}  (sometimes an array)
  #   unlcdv:countryCode        → {"@id":"unlcdc:CN"}             (strip prefix)
  #   unlcdv:countrySubdivision → {"@id":"unlcds:CNSH"}           (strip prefix)
  #   unlcdv:functions          → {"@id":"unlcdf:4"} or [...]     (strip prefix; numeric → letter)
  #   geo:lat / geo:long        → {"@type":"xsd:float","@value":"42.5"}
  #
  # When UNCEFACT publishes new wire names, update the constants below — the
  # Entry model itself does not change.
  class Loader
    FUNCTION_DIGIT_TO_LETTER = {
      '1' => 'B', # sea port
      '2' => 'R', # rail terminal
      '3' => 'T', # road terminal
      '4' => 'A', # airport
      '5' => 'P', # postal exchange office
      '6' => 'I', # inland water transport
      '7' => 'F', # ferry port
      '8' => 'V', # pipeline
      '9' => 'O' # other / border crossing
    }.freeze

    UNLOCODE_TYPE_SUFFIX = 'UNLOCODE'

    class << self
      # Load entries from a file path on disk.
      # @param path [String] absolute or relative path to a JSON-LD file
      # @return [Array<Unlocode::Entry>]
      def load_file(path)
        load_json(File.read(path))
      end

      # Load entries from a JSON-LD string.
      # @param json [String] a JSON-LD document
      # @return [Array<Unlocode::Entry>]
      def load_json(json)
        parse(JSON.parse(json, symbolize_names: false))
      end

      # Load entries from a pre-parsed JSON-LD hash.
      # @param data [Hash] parsed JSON-LD
      # @return [Array<Unlocode::Entry>]
      def parse(data)
        extract_graph(data).filter_map { |node| build_entry(node) if unlocode_node?(node) }
      end

      private

      def extract_graph(data)
        return [] unless data.is_a?(Hash)

        graph = data['@graph']
        if graph.is_a?(Array)
          graph
        elsif data.key?('@id') || data.key?('rdf:value')
          [data]
        else
          []
        end
      end

      def unlocode_node?(node)
        return false unless node.is_a?(Hash)

        types = Array(node['@type']).flat_map { |t| t.to_s.split(/[,\s]+/) }
        types.empty? || types.any? { |t| t.end_with?(UNLOCODE_TYPE_SUFFIX) }
      end

      def build_entry(node)
        Entry.new(
          code: strip_id(node['rdf:value']) || strip_id(node['@id']),
          country: strip_prefixed_id(node['unlcdv:countryCode']),
          subdivision: strip_prefixed_id(node['unlcdv:countrySubdivision']),
          name: pick_label(node['rdfs:label']) || pick_label(node['rdfs:seeAlso']),
          function_codes: pick_function_codes(node['unlcdv:functions']),
          latitude: pick_float(node['geo:lat']),
          longitude: pick_float(node['geo:long'])
        )
      end

      def strip_prefixed_id(value)
        return nil if value.nil?

        case value
        when Hash then strip_id(value['@id'])
        when Array then strip_id(value.first&.dig('@id'))
        when String then strip_id(value)
        end
      end

      def strip_id(value)
        return nil if value.nil? || value.to_s.empty?

        value.to_s.split(':').last
      end

      def pick_label(value)
        return value unless value.is_a?(Hash) || value.is_a?(Array)

        entries = value.is_a?(Array) ? value : [value]
        picked = entries.find { |v| v.is_a?(Hash) && v['@language'] == 'en' } || entries.first
        picked.is_a?(Hash) ? picked['@value'] : picked
      end

      def pick_function_codes(value)
        return [] if value.nil?

        entries = value.is_a?(Array) ? value : [value]
        entries.filter_map do |entry|
          id = strip_prefixed_id(entry)
          next if id.nil?

          FUNCTION_DIGIT_TO_LETTER.fetch(id, id)
        end
      end

      def pick_float(value)
        return nil if value.nil?
        return value['@value']&.to_f if value.is_a?(Hash)

        value.to_f
      end
    end
  end
end
