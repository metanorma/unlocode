# frozen_string_literal: true

require 'lutaml/model'
require_relative 'status'
require_relative 'function'
require_relative 'coordinates'

module Unlocode
  # A single UN/LOCODE entry.
  #
  # Stores wire-level fields as `lutaml-model` attributes and exposes typed
  # helpers (#functions, #coordinates) that convert to {Function} and
  # {Coordinates} value types on demand. The LOCODE itself is the 5-character
  # composite of `country` (ISO 3166-1 alpha-2) + the 3-character location
  # alpha. The `code` attribute is the canonical 5-char string.
  #
  # `latitude` and `longitude` are decimal degrees (WGS-84), populated when
  # the source vocabulary provides `geo:lat` / `geo:long`. Older editions
  # published a single coordinate string ("DDMMNDDDMMME"); see
  # {Coordinates.parse} when converting from that form.
  class Entry < Lutaml::Model::Serializable
    attribute :code, :string
    attribute :country, :string
    attribute :subdivision, :string
    attribute :name, :string
    attribute :function_codes, :string, collection: true
    attribute :latitude, :float
    attribute :longitude, :float

    def functions
      (function_codes || []).map { |code| Function.cast(code) }
    end

    def function?(letter)
      function_codes&.include?(letter.to_s.upcase)
    end

    def coordinates
      return Coordinates.new(latitude: nil, longitude: nil) if latitude.nil? && longitude.nil?

      Coordinates.new(latitude: latitude, longitude: longitude)
    end

    def port?
      function?('B')
    end

    def airport?
      function?('A')
    end

    def rail_terminal?
      function?('R')
    end

    def road_terminal?
      function?('T')
    end

    def ==(other)
      other.is_a?(Entry) && code == other.code
    end

    def hash
      code&.hash || super
    end

    def eql?(other)
      self == other
    end

    def to_s
      "#{code} #{name}".strip
    end
  end
end
