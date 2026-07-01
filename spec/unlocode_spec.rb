# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unlocode do
  after { described_class.reset_registry! }

  describe '.registry' do
    it 'is memoized' do
      expect(described_class.registry).to equal(described_class.registry)
    end

    it 'can be reset' do
      first = described_class.registry
      described_class.reset_registry!
      expect(described_class.registry).not_to equal(first)
    end
  end

  describe 'VERSION' do
    it 'exposes a version string' do
      expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+/)
    end
  end

  describe 'delegated query shortcuts' do
    before do
      registry = Unlocode::Registry.from_entries([
                                                   Unlocode::Entry.new(code: 'CNSHA', country: 'CN', name: 'Shanghai'),
                                                   Unlocode::Entry.new(code: 'USNYC', country: 'US', name: 'New York')
                                                 ])
      allow(described_class).to receive(:registry).and_return(registry)
    end

    it 'delegates find to the registry' do
      expect(described_class.find('CNSHA').name).to eq('Shanghai')
    end

    it 'delegates where to the registry' do
      expect(described_class.where(country: 'CN').map(&:code)).to eq(%w[CNSHA])
    end

    it 'delegates countries to the registry' do
      expect(described_class.countries).to eq(%w[CN US])
    end

    it 'delegates count to the registry' do
      expect(described_class.count).to eq(2)
    end
  end
end
