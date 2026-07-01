# frozen_string_literal: true

require 'forwardable'
require 'lutaml/model'
require 'json'

require_relative 'unlocode/version'

# Vendored UN/LOCODE dataset as a queryable Ruby registry.
#
# The dataset is sourced from the UNECE/UNCEFACT LOCODE vocabulary published at
# https://service.unece.org/trade/locode/ and distributed by this gem as a
# bundled, offline JSON-LD representation. The registry loads once per process
# and exposes a typed query API over `Unlocode::Entry` instances.
module Unlocode
  extend SingleForwardable

  class << self
    # @return [Unlocode::Registry] the process-wide registry, loaded lazily
    def registry
      @registry ||= Registry.load_default
    end

    # Reset the process-wide registry. Used by specs to swap fixtures.
    def reset_registry!
      @registry = nil
    end
  end

  def_delegators :registry, :find, :where, :each, :size, :count, :countries

  autoload :Status, 'unlocode/status'
  autoload :Function, 'unlocode/function'
  autoload :Coordinates, 'unlocode/coordinates'
  autoload :Entry, 'unlocode/entry'
  autoload :Loader, 'unlocode/loader'
  autoload :Registry, 'unlocode/registry'
  autoload :Data, 'unlocode/data'
end
