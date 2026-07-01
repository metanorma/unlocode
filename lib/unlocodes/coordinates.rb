# frozen_string_literal: true

module Unlocodes
  # Geographic coordinates (WGS-84) for a LOCODE entry.
  #
  # Parsed from the LOCODE coordinate string ("DDMM[H]DDDMM[H]" where H is one
  # of N/S/E/W) used by the UN/LOCODE manual and the UNCEFACT vocabulary.
  # Exposes decimal degrees so distance / bounding-box queries are practical.
  class Coordinates
    attr_reader :latitude, :longitude

    def initialize(latitude: nil, longitude: nil)
      @latitude = latitude&.to_f
      @longitude = longitude&.to_f
    end

    # Parse a UN/LOCODE coordinate string like "3108N12150E" into decimal
    # degrees. Accepts shorter / longer minute forms; returns a Coordinates
    # with nil lat/lon when the input is blank or unparseable.
    #
    # @example
    #   Coordinates.parse("3108N12150E")    # => lat 31.133..., lon 121.833...
    #   Coordinates.parse("")               # => nil lat/lon
    def self.parse(text)
      return new(latitude: nil, longitude: nil) if text.nil? || text.to_s.strip.empty?

      m = text.to_s.upcase.strip.match(/\A(\d{2})(\d{2})\s*([NS])\s*
                                         (\d{3})(\d{2})\s*([EW])\Z/x)
      return new(latitude: nil, longitude: nil) unless m

      lat = dms_to_decimal(m[1], m[2], m[3])
      lon = dms_to_decimal(m[4], m[5], m[6])
      new(latitude: lat, longitude: lon)
    end

    def self.dms_to_decimal(deg_str, min_str, hemi)
      dec = deg_str.to_i + (min_str.to_i / 60.0)
      dec = -dec if %w[S W].include?(hemi)
      dec
    end
    private_class_method :dms_to_decimal

    def to_a
      [latitude, longitude].compact
    end

    def ==(other)
      other.is_a?(Coordinates) &&
        latitude == other.latitude &&
        longitude == other.longitude
    end

    def to_s
      return '' if latitude.nil? || longitude.nil?

      format('%<lat>.4f %<lon>.4f', lat: latitude, lon: longitude)
    end

    # Great-circle distance in kilometres to another Coordinates, using the
    # haversine formula. Returns nil if either side lacks coordinates.
    def distance_to(other)
      return nil if latitude.nil? || longitude.nil? ||
                    other.latitude.nil? || other.longitude.nil?

      earth_radius_km = 6371.0
      d_lat = (other.latitude - latitude) * (Math::PI / 180)
      d_lon = (other.longitude - longitude) * (Math::PI / 180)
      a = (Math.sin(d_lat / 2)**2) +
          (Math.cos(latitude * (Math::PI / 180)) *
           Math.cos(other.latitude * (Math::PI / 180)) *
           (Math.sin(d_lon / 2)**2))
      2 * earth_radius_km * Math.asin(Math.sqrt(a))
    end
  end
end
