require 'migration_helper'

module DulHydra::Migration
  RSpec.describe TargetObjectIntegrity do

    subject { described_class.new(source, target) }

    let(:source) { Rubydora::DigitalObject.new('test:1') }
    let(:target) { Component.new }
    let(:target_file) { ActiveFedora::File.new }

    context "datastream not migrated" do
      let(:source_datastream) { Rubydora::Datastream.new(source, 'content') }
      before do
        allow(source).to receive(:datastreams) { [ [ 'content', source_datastream ] ] }
        allow(source_datastream).to receive_message_chain(:content, :present?) { true }
        allow(target).to receive(:attached_files) { { } }
      end
      it "should raise an exception" do
        expect { subject.verify }.to raise_error(FedoraMigrate::Errors::MigrationError)
      end
    end

    context "datastream migrated" do

      context "OM datastream" do
        let(:source_datastream) { Rubydora::Datastream.new(source, 'fits') }
        before do
          allow(source).to receive(:datastreams) { [ [ 'fits', source_datastream ] ] }
          allow(source_datastream).to receive(:content) { '<fits />' }
          allow(target).to receive(:attached_files) { { 'fits' => target_file } }
        end
        describe "when equivalence verification fails on a datastream" do
          before do
            allow(target_file).to receive(:content) { "<?xml version=\"1.0\"?><fats />" }
          end
          it "should raise an exception" do
            expect { subject.verify }.to raise_error(FedoraMigrate::Errors::MigrationError)
          end
        end
        describe "when equivalence verification does not fail on any datastream" do
          before do
            allow(target_file).to receive(:content) { "<?xml version=\"1.0\"?><fits />" }
          end
          it "should not raise an exception" do
            expect { subject.verify }.not_to raise_error
          end
        end
      end

      context "not OM datastream" do
        let(:source_datastream) { Rubydora::Datastream.new(source, 'content') }
        before do
          allow(source).to receive(:datastreams) { [ [ 'content', source_datastream ] ] }
          allow(source_datastream).to receive_message_chain(:content, :present?) { true }
          allow(source_datastream).to receive(:checksum) { '75e2e0cec6e807f6ae63610d46448f777591dd6b' }
          allow(source_datastream).to receive(:checksumType) { 'SHA1' }
          allow(target).to receive(:attached_files) { { 'content' => target_file } }
        end
        describe "when checksum verification fails on a datastream" do
          before do
            allow(target_file).to receive(:digest) { [ RDF::URI.new('urn:sha1:2cf23f0035c12b6242093e93d0f7eeba0b1e08e8') ] }
          end
          it "should raise an exception" do
            expect { subject.verify }.to raise_error(FedoraMigrate::Errors::MigrationError)
          end
        end
        describe "when checksum verification does not fail on any datastream" do
          before do
            allow(target_file).to receive(:digest) { [ RDF::URI.new('urn:sha1:75e2e0cec6e807f6ae63610d46448f777591dd6b') ] }
          end
          it "should not raise an exception" do
            expect { subject.verify }.not_to raise_error
          end
        end
      end

    end

  end
end
