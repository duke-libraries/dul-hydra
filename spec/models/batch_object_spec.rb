require 'spec_helper'

  shared_examples "a valid object" do
    it "should be valid" do
      expect(object.validate.errors).to be_empty
    end
  end
  
  shared_examples "an invalid object" do
    it "should not be valid" do
      expect(object.validate.errors).to include(error_message)
    end
  end

describe BatchObject do
  
  context "ingest object" do
    let(:object) { FactoryGirl.create(:ingest_batch_object_with_datastreams) }
    
    context "valid object" do
      let(:apo) { FactoryGirl.create(:public_read_policy) }
      let(:parent) { FactoryGirl.create(:test_parent) }
      let(:collection) { FactoryGirl.create(:collection) }
      before do
        object.admin_policy = apo.pid
        object.parent = parent.pid
        object.target_for = collection.pid
      end
      after do
        apo.destroy
        parent.destroy
        collection.destroy
      end
      it_behaves_like "a valid object"
    end

    context "invalid object" do
      context "missing model" do
        let(:error_message) { "Model required for INGEST operation" }
        before { object.model = nil }
        it_behaves_like "an invalid object"
      end
      context "invalid model" do
        let(:error_message) { "Invalid model name: #{object.model}" }
        before { object.model = "BadModel" }
        it_behaves_like "an invalid object"
      end
      context "invalid admin policy" do
        context "admin policy pid object does not exist" do
          let(:error_message) { "Specified AdminPolicy does not exist: #{object.admin_policy}" }
          before { object.admin_policy = "bogus:AdminPolicy" }
          it_behaves_like "an invalid object"
        end
        context "admin policy pid object exists but is not admin policy" do
          let(:error_message) { "#{object.admin_policy} exists but is not a(n) AdminPolicy" }
          before do
            @not_admin_policy = FactoryGirl.create(:test_model)
            object.admin_policy = @not_admin_policy.pid
          end
          after { @not_admin_policy.destroy }
          it_behaves_like "an invalid object"
        end
      end
      context "invalid datastreams" do
        context "invalid payload type" do
          let(:error_message) { "Invalid payload_type for #{object.batch_object_datastreams.first[:name]} datastream: #{object.batch_object_datastreams.first[:payload_type]}" }
          before do
            datastream = object.batch_object_datastreams.first
            datastream.payload_type = "invalid_type"
            datastream.save!
          end
          it_behaves_like "an invalid object"
        end
        context "missing data file" do
          let(:error_message) { "Missing or unreadable file for #{object.batch_object_datastreams.last[:name]} datastream: #{object.batch_object_datastreams.last[:payload]}" }
          before do
            datastream = object.batch_object_datastreams.last
            datastream.payload = "non_existent_file.xml"
            datastream.save!
          end
          it_behaves_like "an invalid object"
        end
      end
      context "invalid parent" do
        before { object.model = "TestChild" }
        context "parent pid object does not exist" do
          let(:error_message) { "Specified TestParent does not exist: #{object.parent}" }
          before { object.parent = "bogus:TestParent" }
          it_behaves_like "an invalid object"
        end
        context "parent pid object exists but is not correct parent object type" do
          let(:error_message) { "#{object.parent} exists but is not a(n) TestParent" }
          before do
            @not_parent = FactoryGirl.create(:test_model)
            object.parent = @not_parent.pid
          end
          after { @not_parent.destroy }
          it_behaves_like "an invalid object"
        end
      end
      context "invalid target_for" do
        context "target_for pid object does not exist" do
          let(:error_message) { "Specified Collection does not exist: #{object.target_for}" }
          before { object.target_for = "bogus:Collection" }
          it_behaves_like "an invalid object"
        end
        context "target_for pid object exists but is not collection" do
          let(:error_message) { "#{object.target_for} exists but is not a(n) Collection" }
          before do
            @not_collection = FactoryGirl.create(:test_model)
            object.target_for = @not_collection.pid
          end
          after { @not_collection.destroy }
          it_behaves_like "an invalid object"
        end
      end
    end
  end

end
