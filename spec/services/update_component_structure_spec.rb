RSpec.describe UpdateComponentStructure, type: :service do

  let(:object_id) { 'test:1234' }
  let(:solr_document) { SolrDocument.new(Ddr::Index::Fields::ACTIVE_FEDORA_MODEL => object_model) }
  let(:object_model) { Component.to_s }

  describe ".call" do
    let(:notification_args) { [ 'test', DateTime.now - 2.seconds, DateTime.now - 1.seconds, 'testid', payload ] }
    let(:payload) { { pid: object_id, new_datastreams: new_datastreams, skip_structure_updates: skip_structure_updates } }
    let(:new_datastreams) { [ Ddr::Datastreams::THUMBNAIL ] }
    before do
      allow(SetDefaultStructure).to receive(:new) { double('SetDefaultStructure', enqueue_default_structure_job: nil) }
    end
    around do |example|
      prev_auto_update_structures = DulHydra.auto_update_structures
      DulHydra.auto_update_structures = true
      example.run
      DulHydra.auto_update_structures = prev_auto_update_structures
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
          let(:new_datastreams) { [ Ddr::Datastreams::DESC_METADATA ] }
          let(:skip_structure_updates) { false }
          it "does not update the structure" do
            expect(SetDefaultStructure).to_not receive(:new)
            UpdateComponentStructure.call(*notification_args)
          end
        end
      end
    end
  end

end
