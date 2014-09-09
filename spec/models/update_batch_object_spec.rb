require 'spec_helper'
require 'helpers/metadata_helper'

module DulHydra::Batch::Models

  shared_examples "a valid update object" do
    it "should be valid" do
      expect(object.validate).to be_empty
    end
  end
  
  shared_examples "an invalid update object" do
    it "should not be valid" do
      expect(object.validate).to include(error_message)
    end
  end
  
  describe UpdateBatchObject, type: :model, batch: true do

    let(:batch) { FactoryGirl.create(:batch_with_basic_update_batch_object) }
    let(:object) { batch.batch_objects.first }

    before { allow(File).to receive(:readable?).with("/tmp/qdc-rdf.nt").and_return(true) }

    context "validate", validation: true do
      context "valid object" do
        let(:repo_object) { TestModel.create(:pid => object.pid) }
        before do
          repo_object.edit_users = [ batch.user.user_key ]
          repo_object.save
        end
        context "generic object" do
          it_behaves_like "a valid update object"
        end
        context "generic object without a model attribute" do
          before { object.model = nil }
          it_behaves_like "a valid update object"
        end
      end
      context "invalid object" do
        let(:error_prefix) { "#{object.identifier} [Database ID: #{object.id}]:"}
        context "missing pid" do
          let(:error_message) { "#{error_prefix} PID required for UPDATE operation" }
          before do
            object.pid = nil
            object.save!
          end
          it_behaves_like "an invalid update object"
        end
        context "pid not found in repository" do
          let(:error_message) { "#{error_prefix} PID #{object.pid} not found in repository" }
          it_behaves_like "an invalid update object"
        end
        context "batch user not permitted to edit repository object" do
          let!(:repo_object) { TestModel.create(:pid => object.pid) }
          let(:error_message) { "#{error_prefix} #{batch.user.user_key} not permitted to edit #{object.pid}" }
          it_behaves_like "an invalid update object"          
        end
      end
    end

    context "update" do
      context "successful update" do
        let(:repo_object) { TestModel.create(pid: object.pid, title: [ "Test Model Title" ]) }
        before do
          allow(File).to receive(:read).with("/tmp/qdc-rdf.nt").and_return(sample_metadata_triples("<#{repo_object.descMetadata.rdf_subject.to_s}>"))
          repo_object.edit_users = [batch.user.user_key]
          repo_object.save!
          object.process(batch.user)
          repo_object.reload
        end
        it "should update the repository object" do
          expect(repo_object.title.first).to eq('Sample title')
        end
        it "should create an event log for the update" do
          expect(repo_object.update_events.count).to eq(2)
          expect(repo_object.update_events.last.comment).to eq("Updated by batch process (Batch #{object.batch.id}, BatchObject #{object.id})")
        end
        
      end
      
    end
    
  end
  
end
