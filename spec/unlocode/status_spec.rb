# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unlocode::Status do
  describe '.cast' do
    it 'wraps a code string in a Status instance' do
      status = described_class.cast('AA')
      expect(status).to be_a(described_class)
      expect(status.code).to eq('AA')
    end

    it 'uppercases the code' do
      expect(described_class.cast('aa').code).to eq('AA')
    end

    it 'returns nil for nil' do
      expect(described_class.cast(nil)).to be_nil
    end

    it 'is idempotent on Status instances' do
      status = described_class.cast('AA')
      expect(described_class.cast(status)).to equal(status)
    end
  end

  describe '#description' do
    it 'looks up known codes' do
      expect(described_class.cast('AA').description).to eq('Approved')
      expect(described_class.cast('XX').description).to eq('Deleted, no replacement')
    end

    it 'returns nil for unknown codes' do
      expect(described_class.cast('ZZ').description).to be_nil
    end
  end

  describe '.description' do
    it 'is callable as a class method' do
      expect(described_class.description('RL')).to eq('Replaced, linked')
    end
  end

  describe '.known?' do
    it 'returns true for documented status codes' do
      expect(described_class).to be_known('AA')
      expect(described_class).to be_known('XX')
    end

    it 'returns false for unknown codes' do
      expect(described_class).not_to be_known('ZZ')
    end
  end

  describe '#to_s' do
    it 'returns the code string' do
      expect(described_class.cast('AA').to_s).to eq('AA')
    end
  end
end
