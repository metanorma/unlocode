# frozen_string_literal: true

# Bundled UN/LOCODE dataset.
#
# `locode.jsonld` is populated by `rake unlocode:fetch` and is the source
# loaded by `Unlocode::Registry.load_default`.
module Unlocode
  module Data
    autoload :Fetcher, "#{__dir__}/data/fetcher"
  end
end
