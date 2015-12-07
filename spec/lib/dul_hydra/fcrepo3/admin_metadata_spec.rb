require "spec_helper"
require "dul_hydra/fcrepo3/admin_metadata"
require "rubydora"
require "rdf/isomorphic"

module DulHydra::Fcrepo3
  RSpec.describe AdminMetadata do

    subject { described_class.new(datastream) }

    let(:f3_ntriples) { fixture_file_upload("fcrepo3/f3_adminMetadata.nt") }
    let(:f4_ntriples) { fixture_file_upload("fcrepo3/f4_adminMetadata.nt") }
    let(:datastream) { ::Rubydora::Datastream.new(nil, nil, content: f3_ntriples) }

    before {
      allow(datastream).to receive(:pid) { "duke:141764" }
    }

    describe "#f3_graph" do
      it "creates an RDF graph of the F3 source data" do
        expect(subject.f3_graph.dump(:ntriples)).to eq(f3_ntriples.read)
      end
    end

    describe "#f4_graph" do
      it "creates an RDF graph for the F4 target" do
        f4_graph = ::RDF::Graph.new.from_ntriples(f4_ntriples.read)
        expect(subject.f4_graph).to be_isomorphic_with(f4_graph)
      end
    end

    describe ".convert!" do
      it "converts the datastream content from F3 to F4 content" do
        expect { described_class.convert!(datastream) }
          .to change(datastream, :content)
               .to(f4_ntriples.read)
      end
    end

  end
end
