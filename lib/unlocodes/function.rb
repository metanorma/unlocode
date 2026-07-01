# frozen_string_literal: true

module Unlocodes
  # UN/LOCODE function classifier.
  #
  # Single-letter codes identifying the transport function a LOCODE serves.
  # A single LOCODE entry can carry several function codes simultaneously
  # (e.g. "BA" = sea port and airport).
  # Source: UN/LOCODE manual, "Code list for function".
  #
  # Plain value wrapper rather than a `Lutaml::Model::Type::Value` subclass:
  # the wire-level code letters live on the {Entry} as a `:string` collection,
  # and {Entry#functions} wraps each on demand.
  class Function
    DESCRIPTIONS = {
      'B' => 'Port (sea)',
      'R' => 'Rail terminal',
      'T' => 'Road terminal',
      'A' => 'Airport',
      'P' => 'Postal exchange office',
      'I' => 'Inland water transport (river)',
      'F' => 'Ferry port',
      'V' => 'Pipeline',
      'O' => 'Other (border crossing, etc.)',
      '0' => 'Function not known',
      '1' => 'Not provided'
    }.freeze

    attr_reader :code

    def initialize(code)
      @code = code.to_s.upcase
    end

    class << self
      # @return [Function, nil] nil for nil input
      def cast(value)
        return nil if value.nil?
        return value if value.is_a?(Function)

        new(value)
      end

      def description(code)
        DESCRIPTIONS[code.to_s.upcase]
      end

      def known?(code)
        DESCRIPTIONS.key?(code.to_s.upcase)
      end
    end

    def description
      self.class.description(@code)
    end

    def known?
      self.class.known?(@code)
    end

    def to_s
      @code
    end

    def ==(other)
      other.is_a?(Function) && code == other.code
    end

    alias eql? ==
    alias hash code
  end
end
