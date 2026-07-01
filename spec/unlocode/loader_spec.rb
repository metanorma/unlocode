# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unlocode::Loader do
  let(:sample_path) { File.join(FIXTURES_DIR, 'locode_sample.jsonld') }
  let(:sample_json) { File.read(sample_path) }

  describe '.load_file' do
    it 'reads a JSON-LD file from disk' do
      entries = described_class.load_file(sample_path)
      expect(entries).to all(be_a(Unlocode::Entry))
      expect(entries.map(&:code).sort).to eq(%w[CNSHA HKHKG NLRTM USNYC])
    end
  end

  describe '.load_json' do
    it 'parses a JSON-LD string into Entry instances' do
      entries = described_class.load_json(sample_json)
      expect(entries.size).to eq(4)
    end

    it 'returns an empty array for an empty graph' do
      entries = described_class.load_json({ '@context' => {}, '@graph' => [] }.to_json)
      expect(entries).to eq([])
    end

    it 'returns an empty array for a document with no graph' do
      entries = described_class.load_json({ '@context' => {} }.to_json)
      expect(entries).to eq([])
    end

    it 'skips non-UNLOCODE graph entries' do
      json = {
        '@graph' => [
          { '@type' => 'skos:ConceptScheme', '@id' => 'urn:locode' },
          { '@type' => 'unlcdv:UNLOCODE', 'rdf:value' => 'CNSHA' }
        ]
      }.to_json
      entries = described_class.load_json(json)
      expect(entries.map(&:code)).to eq(['CNSHA'])
    end
  end

  describe '.parse' do
    it 'builds Entry attributes from real UNCEFACT wire names' do
      parsed = JSON.parse(sample_json)
      entries = described_class.parse(parsed)
      shanghai = entries.find { |e| e.code == 'CNSHA' }

      expect(shanghai.country).to eq('CN')
      expect(shanghai.subdivision).to eq('CNSH')
      expect(shanghai.name).to eq('Shanghai')
      expect(shanghai.function_codes).to eq(%w[B A P])
      expect(shanghai.latitude).to eq(31.2)
      expect(shanghai.longitude).to eq(121.4)
    end

    it 'maps unlcdf numeric ids to function letters (1→B, 4→A)' do
      parsed = JSON.parse(sample_json)
      shanghai = described_class.parse(parsed).find { |e| e.code == 'CNSHA' }
      expect(shanghai.function_codes).to eq(%w[B A P]) # 1, 4, 5 → B, A, P
    end

    it 'handles rdfs:label as an array (picks the @language=en entry)' do
      parsed = { '@graph' => [{
        '@type' => 'unlcdv:UNLOCODE',
        'rdf:value' => 'ADSJL',
        'rdfs:label' => [
          { '@value' => 'Sant Julià de Lòria' },
          { '@language' => 'en', '@value' => 'Sant Julia de Loria' }
        ]
      }] }
      entry = described_class.parse(parsed).first
      expect(entry.name).to eq('Sant Julia de Loria')
    end

    it 'strips prefixes from unlcdv:countryCode @id references' do
      parsed = { '@graph' => [{
        '@type' => 'unlcdv:UNLOCODE',
        'rdf:value' => 'XXXXX',
        'unlcdv:countryCode' => { '@id' => 'unlcdc:XX' }
      }] }
      expect(described_class.parse(parsed).first.country).to eq('XX')
    end

    it 'falls back to @id suffix when rdf:value is missing' do
      parsed = { '@graph' => [{
        '@type' => 'unlcdv:UNLOCODE',
        '@id' => 'unlcd:CNSHA'
      }] }
      expect(described_class.parse(parsed).first.code).to eq('CNSHA')
    end

    it 'leaves attributes nil when the wire data is missing' do
      entry = described_class.parse(
        { '@graph' => [{ '@type' => 'unlcdv:UNLOCODE', 'rdf:value' => 'USNYC' }] }
      ).first
      expect(entry.country).to be_nil
      expect(entry.function_codes).to be_empty
      expect(entry.latitude).to be_nil
      expect(entry.longitude).to be_nil
    end

    it 'handles a single function as a hash (not array)' do
      parsed = { '@graph' => [{
        '@type' => 'unlcdv:UNLOCODE',
        'rdf:value' => 'XXXXX',
        'unlcdv:functions' => { '@id' => 'unlcdf:4' }
      }] }
      expect(described_class.parse(parsed).first.function_codes).to eq(['A'])
    end

    it 'preserves unknown function ids (e.g. letters) as-is' do
      parsed = { '@graph' => [{
        '@type' => 'unlcdv:UNLOCODE',
        'rdf:value' => 'XXXXX',
        'unlcdv:functions' => [{ '@id' => 'unlcdf:B' }]
      }] }
      expect(described_class.parse(parsed).first.function_codes).to eq(['B'])
    end
  end
end
