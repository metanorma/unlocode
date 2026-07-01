# frozen_string_literal: true

require 'unlocode'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.after do
    Unlocode.reset_registry!
  end
end

FIXTURES_DIR = File.expand_path('fixtures', __dir__)
