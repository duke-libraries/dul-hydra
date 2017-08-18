require 'spec_helper'

RSpec.describe UpdateComponentStructure, type: :service do

  let(:object_id) { 'test:1234' }

  describe ".call" do
    let(:notification_args) { [ 'test', DateTime.now - 2.seconds, DateTime.now - 1.seconds, 'testid', payload ] }
    let(:payload) { { pid: object_id, file_id: file_id, skip_structure_updates: skip_structure_updates } }
    let(:file_id) { Ddr::Datastreams::THUMBNAIL }
    let(:solr_document) { SolrDocument.new(Ddr::Index::Fields::ACTIVE_FEDORA_MODEL => object_model) }
    let(:object_model) { Component.to_s }
    before do
      allow(SetDefaultStructure).to receive(:new) { double('SetDefaultStructure', enqueue_default_structure_job: nil) }
    end
    describe "skip structure updating" do
      let(:skip_structure_updates) { true }
      it "does not update the structure" do
        expect(SetDefaultStructure).to_not receive(:new)
        UpdateComponentStructure.call(*notification_args)
      end
    end
    describe "do not skip structure updating" do
      describe "component" do
        before { allow(SolrDocument).to receive(:find).with(object_id) { solr_document } }
        describe "structurally relevant datastream" do
          let(:skip_structure_updates) { false }
          it "updates the structure" do
            expect(SetDefaultStructure).to receive(:new).with(object_id)
            UpdateComponentStructure.call(*notification_args)
          end
        end
        describe "not structurally relevant datastream" do
          let(:file_id) { Ddr::Datastreams::DESC_METADATA }
          let(:skip_structure_updates) { false }
          it "does not update the structure" do
            expect(SetDefaultStructure).to_not receive(:new)
            UpdateComponentStructure.call(*notification_args)
          end
        end
      end
      describe "not component" do
        before { allow(SolrDocument).to receive(:find).with(object_id) { solr_document } }
        let(:skip_structure_updates) { false }
        let(:object_model) { Item.to_s }
        it "does not update the structure" do
          expect(SetDefaultStructure).to_not receive(:new).with(object_id)
          UpdateComponentStructure.call(*notification_args)
        end
      end
    end
  end

end
