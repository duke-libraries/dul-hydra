require 'spec_helper'

module DulHydra::BatchIngest

  shared_examples "a valid object" do
    it "should be valid" do
      expect(object.valid?).to be_true
      expect(object.validate).to be_empty
    end
  end
  
  shared_examples "an invalid object" do
    it "should not be valid" do
      expect(object.valid?).to be_false
      expect(object.validate).to include(error_message)
    end
  end

  describe IngestObject do
    
    context "valid object" do
      context "not child object" do
        let(:object) { FactoryGirl.build(:test_model_ingest_object) }
        let(:apo) { FactoryGirl.create(:public_read_policy) }
        let(:collection) { FactoryGirl.create(:collection) }
        before do
          object.admin_policy = apo.pid
          object.collection = collection.pid
        end
        after do
          apo.destroy
          collection.destroy
        end
        it_behaves_like "a valid object"
      end
      context "child object" do
        let(:object) { FactoryGirl.build(:test_child_ingest_object) }
        let(:parent) { FactoryGirl.create(:test_parent) }
        before { object.parent = parent.pid }
        after { parent.destroy }
        it_behaves_like "a valid object"
      end
    end
    
    context "invalid object" do
      let(:object) { FactoryGirl.build(:ingest_object) }
      context "missing model" do
        let(:error_message) { "Missing model name" }
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
      context "invalid data" do
        context "invalid payload type" do
          let(:error_message) { "Invalid payload_type for #{object.data.first[:datastream_name]} datastream: #{object.data.first[:payload_type]}" }
          before { object.data = [ { :datastream_name => 'datastream', :payload => '<foo>bar</foo>', :payload_type => "invalid_type" } ] }
          it_behaves_like "an invalid object"
        end
        context "missing data file" do
          let(:error_message) { "Missing or unreadable file for #{object.data.first[:datastream_name]} datastream: #{object.data.first[:payload]}" }
          before { object.data = [ { :datastream_name => DulHydra::Datastreams::CONTENT, :payload => 'non_existent_file.xml', :payload_type => "filename" } ] }
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
      context "invalid collection" do
        context "collection pid object does not exist" do
          let(:error_message) { "Specified Collection does not exist: #{object.collection}" }
          before { object.collection = "bogus:Collection" }
          it_behaves_like "an invalid object"
        end
        context "collection pid object exists but is not collection" do
          let(:error_message) { "#{object.collection} exists but is not a(n) Collection" }
          before do
            @not_collection = FactoryGirl.create(:test_model)
            object.collection = @not_collection.pid
          end
          after { @not_collection.destroy }
          it_behaves_like "an invalid object"
        end
      end
    end
  
  end

end