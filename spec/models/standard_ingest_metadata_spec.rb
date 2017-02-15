require 'spec_helper'

describe StandardIngestMetadata, type: :model, batch: true, standard_ingest: true do

  let(:metadata_profile) do
    { csv: {
            encoding: "UTF-8",
            headers: true,
            header_converters: :canonicalize
           },
      parse: {
              locator_field_count: 2,
              repeating_fields_separator: ";",
              repeatable_fields: [ "contributor", "creator", "date", "subject", "type" ]
             }
    }
  end

  describe "initialization" do
    context "header validation" do
      context "no invalid headers" do
        let(:metadata_filepath) { Rails.root.join('spec', 'fixtures', 'batch_ingest', 'standard_ingest', 'metadata.txt') }
        it "should not raise an exception" do
          expect { described_class.new(metadata_filepath, metadata_profile) }.to_not raise_error
        end
      end
      context "invalid headers" do
        let(:metadata_filepath) { Rails.root.join('spec', 'fixtures', 'batch_ingest', 'standard_ingest', 'bad-headers-metadata.txt') }
        it "should raise an exception" do
          expect { described_class.new(metadata_filepath, metadata_profile) }.to raise_error(ArgumentError, /bad, alsoBad/)
        end
      end
    end
  end

  describe "metadata" do
    let(:metadata_filepath) { Rails.root.join('spec', 'fixtures', 'batch_ingest', 'standard_ingest', 'metadata.txt') }
    let(:sim) { described_class.new(metadata_filepath, metadata_profile) }
    let(:expected_metadata) do
      {
        nil => { "identifier" => [ "test" ],
                 "title" => [ "Top Title" ],
                 "description" => [ "Top Description" ],
                 "creator" => [ "Spade, Sam" ],
                 "local_id" => [ "spade" ],
                 "setting" => [ "Europe" ] },
        'foo' => { "identifier" => [ "test123" ],
                   "title" => [ "My Title" ],
                   "description" => [ "Description" ],
                   "subject" => [ "Alpha", "Beta" ],
                   "dateSubmitted" => [ "2014-02-03" ],
                   "creator" => [ "Jane Smith" ],
                   "local_id" => [ "spade001" ],
                   "setting" => [ "Great Britain" ] },
        'foo/bar.doc' => { "identifier" => [ "test12345" ],
                           "title" => [ "Updated Title" ],
                           "description" => [ "This is some description; this is \"some more\" description." ],
                           "subject" => [ "Alpha", "Beta", "Gamma", "Delta", "Epsilon" ],
                           "contributor" => [ "Jane Doe" ],
                           "dateSubmitted" => [ "2010-01-22" ],
                           "creator" => [ "John Doe" ],
                           "local_id" => [ "spade001001" ] }
      }
    end
    it "should return the correct metadata for a locator" do
      expect(sim.metadata('foo')).to eql(expected_metadata[ 'foo' ])
      expect(sim.metadata('foo/bar.doc')).to eql(expected_metadata[ 'foo/bar.doc' ])
      expect(sim.metadata('foo/not.doc')).to be_empty
    end
  end

  describe "locators" do
    let(:metadata_filepath) { Rails.root.join('spec', 'fixtures', 'batch_ingest', 'standard_ingest', 'metadata.txt') }
    let(:sim) { described_class.new(metadata_filepath, metadata_profile) }
    it "should return the locators" do
      expect(sim.locators).to match_array([ nil, 'foo', 'foo/bar.doc' ])
    end
  end

end
