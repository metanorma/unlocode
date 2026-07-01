# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unlocode::Function do
  describe '.cast' do
    it 'wraps a single-letter code in a Function instance' do
      fn = described_class.cast('B')
      expect(fn).to be_a(described_class)
      expect(fn.code).to eq('B')
    end

    it 'uppercases the code' do
      expect(described_class.cast('b').code).to eq('B')
    end

    it 'returns nil for nil' do
      expect(described_class.cast(nil)).to be_nil
    end
  end

  describe '#description' do
    it 'looks up known function codes' do
      expect(described_class.cast('B').description).to eq('Port (sea)')
      expect(described_class.cast('A').description).to eq('Airport')
      expect(described_class.cast('R').description).to eq('Rail terminal')
    end

    it 'returns nil for unknown codes' do
      expect(described_class.cast('Z').description).to be_nil
    end
  end

  describe '.known?' do
    it 'returns true for documented function codes' do
      %w[B R T A P I F V O].each do |letter|
        expect(described_class).to be_known(letter)
      end
    end
  end

  describe '#to_s' do
    it 'returns the code letter' do
      expect(described_class.cast('B').to_s).to eq('B')
    end
  end
end
