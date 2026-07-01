# frozen_string_literal: true

module Unlocodes
  # UN/LOCODE status (change indicator).
  #
  # Two-letter codes documenting how a LOCODE entry was last amended relative
  # to the previous edition. Source: UN/LOCODE manual, "Code list for status".
  #
  # Plain value wrapper rather than a `Lutaml::Model::Type::Value` subclass:
  # the wire-level code string lives on the {Entry} as a `:string` attribute,
  # and {Entry#status} wraps it on demand.
  class Status
    DESCRIPTIONS = {
      'AA' => 'Approved',
      'AC' => 'Added, alternate name',
      'AD' => 'Added, different name',
      'AM' => 'Added, modified name',
      'AQ' => 'Approved, alternate name',
      'AS' => 'Approved, secondary name',
      'RL' => 'Replaced, linked',
      'RN' => 'Replaced, not linked',
      'RS' => 'Replaced, secondary name',
      'RT' => 'Replaced, temporary',
      'UA' => 'Updated, alternate name',
      'UX' => 'Updated, secondary name',
      'XX' => 'Deleted, no replacement',
      'RJ' => 'Rejected',
      'RQ' => 'Requested'
    }.freeze

    attr_reader :code

    def initialize(code)
      @code = code.to_s.upcase
    end

    class << self
      # @return [Status, nil] nil for nil input
      def cast(value)
        return nil if value.nil?
        return value if value.is_a?(Status)

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
      other.is_a?(Status) && code == other.code
    end

    alias eql? ==
    alias hash code
  end
end
