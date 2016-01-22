require 'migration_helper'

module DulHydra::Migration
  RSpec.describe SourceObjectIntegrity do

    subject { described_class.new(source) }

    let(:source) { Rubydora::DigitalObject.new('test:1') }
    let(:datastream) { Rubydora::Datastream.new(source, 'content') }

    before do
      allow(source).to receive(:datastreams) { [ [ 'content', datastream ] ] }
    end

    describe "when checksum validation fails on a datastream" do
      before do
        allow(datastream).to receive(:dsChecksumValid) { false }
      end
      it "should raise an exception" do
        expect { subject.verify }.to raise_error(FedoraMigrate::Errors::MigrationError)
      end
    end

    describe "when checksum validation does not fail on any datastream" do
      before do
        allow(datastream).to receive(:dsChecksumValid) { true }
      end
      it "should not raise an exception" do
        expect { subject.verify }.not_to raise_error
      end
    end

  end
end
