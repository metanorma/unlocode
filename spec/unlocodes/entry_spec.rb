# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unlocodes::Entry do
  let(:entry) do
    described_class.new(
      code: 'CNSHA',
      country: 'CN',
      subdivision: 'SH',
      name: 'Shanghai',
      function_codes: %w[B A P],
      latitude: 31.2,
      longitude: 121.4
    )
  end

  describe 'attribute accessors' do
    it 'exposes code, country, subdivision, name, function_codes, lat/lon' do
      expect(entry.code).to eq('CNSHA')
      expect(entry.country).to eq('CN')
      expect(entry.subdivision).to eq('SH')
      expect(entry.name).to eq('Shanghai')
      expect(entry.function_codes).to eq(%w[B A P])
      expect(entry.latitude).to eq(31.2)
      expect(entry.longitude).to eq(121.4)
    end
  end

  describe '#functions' do
    it 'wraps each code in a Unlocodes::Function' do
      expect(entry.functions).to all(be_a(Unlocodes::Function))
      expect(entry.functions.map(&:code)).to eq(%w[B A P])
    end

    it 'returns an empty array when function_codes is nil' do
      entry = described_class.new(code: 'XXXXX')
      expect(entry.functions).to eq([])
    end
  end

  describe '#function?' do
    it 'matches function letters case-insensitively' do
      expect(entry).to be_function('B')
      expect(entry).to be_function('b')
      expect(entry).not_to be_function('R')
    end
  end

  describe 'function predicates' do
    it '#port?, #airport?, #rail_terminal?, #road_terminal?' do
      expect(entry).to be_port
      expect(entry).to be_airport
      expect(entry).not_to be_rail_terminal
      expect(entry).not_to be_road_terminal
    end
  end

  describe '#coordinates' do
    it 'wraps lat/lon in a Coordinates value type' do
      coords = entry.coordinates
      expect(coords).to be_a(Unlocodes::Coordinates)
      expect(coords.latitude).to eq(31.2)
      expect(coords.longitude).to eq(121.4)
    end

    it 'returns nil lat/lon when both attributes are nil' do
      coords = described_class.new(code: 'XXXXX').coordinates
      expect(coords.latitude).to be_nil
      expect(coords.longitude).to be_nil
    end
  end

  describe 'equality' do
    it 'compares entries by code' do
      same = described_class.new(code: 'CNSHA', name: 'different')
      other = described_class.new(code: 'USNYC')
      expect(entry).to eq(same)
      expect(entry).not_to eq(other)
      expect(entry.eql?(same)).to be true
    end
  end

  describe '#to_s' do
    it 'renders code + name' do
      expect(entry.to_s).to eq('CNSHA Shanghai')
    end

    it 'renders code alone when name is nil' do
      expect(described_class.new(code: 'XXXXX').to_s).to eq('XXXXX')
    end
  end
end
