require "migration_helper"

module DulHydra::Migration
  RSpec.describe RDFDatastreamMerger do

    subject { described_class.new(mover) }

    let(:source) { ::Rubydora::DigitalObject.new("duke:1") }
    let(:target) { Item.new }
    let(:mover) { double(source: source, target: target) }
    let(:f3_admin_metadata_ntriples) do
      <<-EOS
        <info:fedora/duke:1> <http://repository.lib.duke.edu/vocab/asset/permanentId> "ark:/87924/r3mw29095" .
        <info:fedora/duke:1> <http://repository.lib.duke.edu/vocab/asset/permanentUrl> "http://id.library.duke.edu/ark:/87924/r3mw29095" .
        <info:fedora/duke:1> <http://repository.lib.duke.edu/vocab/asset/adminSet> "dc" .
      EOS
    end
    let(:f3_desc_metadata_ntriples) do
      <<-EOS
        <info:fedora/duke:1> <http://purl.org/dc/terms/title> "Project proposal: My Unfinished Project " .
        <info:fedora/duke:1> <http://purl.org/dc/terms/type> "Text" .
      EOS
    end
    let(:f3_merged_metadata_ntriples) { [ f3_admin_metadata_ntriples, f3_desc_metadata_ntriples ].join("\n") }
    let(:admin_metadata_ds) { ::Rubydora::Datastream.new(nil, nil, { content: f3_admin_metadata_ntriples }) }
    let(:desc_metadata_ds) { ::Rubydora::Datastream.new(nil, nil, { content: f3_desc_metadata_ntriples }) }
    let(:nonexistent_ds) { ::Rubydora::Datastream.new(nil, nil, {}) }

    context "both admin metadata and desc metadata" do
      before do
        allow(source).to receive(:datastreams) { { "adminMetadata" => admin_metadata_ds,
                                                   "descMetadata" => desc_metadata_ds,
                                                   "mergedMetadata" => nonexistent_ds } }
      end
      it "merges the content of the two datastreams" do
        subject.merge
        expect(source.datastreams['mergedMetadata'].content).to eq(f3_merged_metadata_ntriples)
      end
    end

    context "only admin metadata" do
      before do
        allow(source).to receive(:datastreams) { { "adminMetadata" => admin_metadata_ds,
                                                   "descMetadata" => nonexistent_ds,
                                                   "mergedMetadata" => nonexistent_ds } }
      end
      it "merges the content of the two datastreams" do
        subject.merge
        expect(source.datastreams['mergedMetadata'].content).to eq("#{f3_admin_metadata_ntriples}\n")
      end
    end

    context "only desc metadata" do
      before do
        allow(source).to receive(:datastreams) { { "adminMetadata" => nonexistent_ds,
                                                   "descMetadata" => desc_metadata_ds,
                                                   "mergedMetadata" => nonexistent_ds } }
      end
      it "merges the content of the two datastreams" do
        subject.merge
        expect(source.datastreams['mergedMetadata'].content).to eq("\n#{f3_desc_metadata_ntriples}")
      end
    end

    context "neither admin metadata nor desc metadata" do
      before do
        allow(source).to receive(:datastreams) { { "adminMetadata" => nonexistent_ds,
                                                   "descMetadata" => nonexistent_ds,
                                                   "mergedMetadata" => nonexistent_ds } }
      end
      it "merges the content of the two datastreams" do
        subject.merge
        expect(source.datastreams['mergedMetadata'].content).to be_nil
      end
    end

  end
end
