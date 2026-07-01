# frozen_string_literal: true

# Bundled UN/LOCODE dataset.
#
# `locode.jsonld` is populated by `rake unlocode:fetch` and is the source
# loaded by `Unlocodes::Registry.load_default`.
module Unlocodes
  module Data
    autoload :Fetcher, "#{__dir__}/data/fetcher"
  end
end
