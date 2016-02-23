require 'migration_helper'

module DulHydra::Migration
  RSpec.describe DatastreamLabel do

    subject { described_class.new(mover) }

    let(:source) { Rubydora::DigitalObject.new('duke:1') }
    let(:target) { ActiveFedora::Base.new }
    let(:mover) { double(source: source, target: target) }

    describe 'content' do
      let(:content_ds) { Rubydora::Datastream.new(source, 'content') }
      let(:admin_metadata_ds) { Rubydora::Datastream.new(source, 'adminMetadata') }
      let(:f3_admin_metadata_ntriples) do
        <<-EOS
        <info:fedora/duke:1> <http://repository.lib.duke.edu/vocab/asset/permanentId> "ark:/87924/r3mw29095" .
        <info:fedora/duke:1> <http://repository.lib.duke.edu/vocab/asset/permanentUrl> "http://id.library.duke.edu/ark:/87924/r3mw29095" .
        <info:fedora/duke:1> <http://www.loc.gov/premis/rdf/v1#hasOriginalName> "abc001.tif" .
        <info:fedora/duke:1> <http://repository.lib.duke.edu/vocab/asset/adminSet> "dc" .
        EOS
      end
      before do
        allow(source).to receive(:datastreams) { { 'adminMetadata' => admin_metadata_ds, 'content' => content_ds } }
        allow(content_ds).to receive(:content) { '100011001' }
        allow(admin_metadata_ds).to receive(:content) { f3_admin_metadata_ntriples }
        expect(content_ds).to receive(:dsLabel=).with('abc001.tif')
      end
      it 'should set the datastream label to the admin metadata original filename' do
        subject.prepare
      end
    end

    describe 'thumbnail' do
      let(:datastream) { Rubydora::Datastream.new(source, 'thumbnail') }
      before do
        allow(source).to receive(:datastreams) { { 'thumbnail' => datastream } }
        allow(datastream).to receive(:content) { '011100110' }
        expect(datastream).to receive(:dsLabel=).with('thumbnail.png')
      end
      it 'should set the datastream label to thumbnail.png' do
        subject.prepare
      end
    end

    describe 'fits' do
      let(:datastream) { Rubydora::Datastream.new(source, 'fits') }
      before do
        allow(source).to receive(:datastreams) { { 'fits' => datastream } }
        allow(datastream).to receive(:content) { '<fits />' }
        expect(datastream).to receive(:dsLabel=).with(nil)
      end
      it 'should set the datastream label to nil' do
        subject.prepare
      end
    end

    describe 'extractedText' do
      let(:datastream) { Rubydora::Datastream.new(source, 'extractedText') }
      before do
        allow(source).to receive(:datastreams) { { 'extractedText' => datastream } }
        allow(datastream).to receive(:content) { 'The quick' }
        expect(datastream).to receive(:dsLabel=).with(nil)
      end
      it 'should set the datastream label to nil' do
        subject.prepare
      end
    end
  end

end

