# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unlocode::Coordinates do
  describe '.parse' do
    it 'parses DDMM[H]DDDMM[H] coordinate strings' do
      coords = described_class.parse('3108N12150E')
      expect(coords.latitude).to be_within(0.0001).of(31.1333)
      expect(coords.longitude).to be_within(0.0001).of(121.8333)
    end

    it 'handles western and southern hemispheres' do
      coords = described_class.parse('4042N07400W')
      expect(coords.latitude).to be_within(0.0001).of(40.7)
      expect(coords.longitude).to be_within(0.0001).of(-74.0)
    end

    it 'returns nil lat/lon for blank input' do
      coords = described_class.parse(nil)
      expect(coords.latitude).to be_nil
      expect(coords.longitude).to be_nil
    end

    it 'returns nil lat/lon for empty string' do
      coords = described_class.parse('')
      expect(coords.latitude).to be_nil
      expect(coords.longitude).to be_nil
    end

    it 'tolerates surrounding whitespace and lowercase' do
      coords = described_class.parse(' 3108n12150e ')
      expect(coords.latitude).to be_within(0.0001).of(31.1333)
    end
  end

  describe '#distance_to' do
    it 'computes the great-circle distance between two points' do
      shanghai = described_class.parse('3108N12150E')
      hong_kong = described_class.parse('2215N11410E')
      distance = shanghai.distance_to(hong_kong)
      expect(distance).to be_within(50).of(1230) # ~1230km SHA↔HKG
    end

    it 'returns 0 for identical coordinates' do
      point = described_class.new(latitude: 1.0, longitude: 2.0)
      expect(point.distance_to(point)).to be_within(0.001).of(0.0)
    end

    it 'returns nil when either side has nil coordinates' do
      point = described_class.parse('3108N12150E')
      empty = described_class.parse('')
      expect(point.distance_to(empty)).to be_nil
      expect(empty.distance_to(point)).to be_nil
    end
  end

  describe '#to_s' do
    it 'formats to 4 decimal places' do
      coords = described_class.new(latitude: 31.1333, longitude: 121.8333)
      expect(coords.to_s).to eq('31.1333 121.8333')
    end

    it 'returns empty string when coords are nil' do
      expect(described_class.parse(nil).to_s).to eq('')
    end
  end

  describe '#==' do
    it 'compares by lat/lon' do
      a = described_class.new(latitude: 1.0, longitude: 2.0)
      b = described_class.new(latitude: 1.0, longitude: 2.0)
      c = described_class.new(latitude: 3.0, longitude: 4.0)
      expect(a).to eq(b)
      expect(a).not_to eq(c)
    end
  end
end
