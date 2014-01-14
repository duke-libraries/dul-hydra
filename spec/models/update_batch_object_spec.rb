require 'spec_helper'

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
  
  describe UpdateBatchObject, batch: true do

    let(:batch) { FactoryGirl.create(:batch_with_basic_update_batch_object) }
    let(:object) { batch.batch_objects.first }

    after do
      batch.user.destroy
      batch.destroy
    end
    
    context "validate" do
      context "valid object" do
        let(:repo_object) { TestModel.create(:pid => object.pid) }
        let(:apo) { FactoryGirl.create(:group_edit_policy) }
        before do
          repo_object.admin_policy = apo
          repo_object.save
        end
        after do
          repo_object.destroy
          apo.destroy
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
          after { repo_object.destroy }
          it_behaves_like "an invalid update object"          
        end
      end
    end

    context "update" do
      context "successful update" do
        let(:repo_object) { TestModel.create(:pid => object.pid) }
        let(:apo) { FactoryGirl.create(:group_edit_policy) }
        before do
          repo_object.admin_policy = apo
          repo_object.save
          object.process
          repo_object.reload
        end
        after do
          repo_object.destroy
          apo.destroy
        end
        it "should update the repository object" do
          expect(repo_object.title.first).to eq('Sample updated title')
        end
        
      end
      
    end
    
  end
  
end
