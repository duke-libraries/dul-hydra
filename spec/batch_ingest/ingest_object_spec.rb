require 'spec_helper'

module DulHydra::BatchIngest

  shared_examples "a valid object" do
    it "should be valid" do
      expect(object.valid?).to be_true
      expect(object.validate.errors).to be_empty
    end
  end
  
  shared_examples "an invalid object" do
    it "should not be valid" do
      expect(object.valid?).to be_false
      expect(object.validate.errors).to include(error_message)
    end
  end

  describe IngestObject do
    
    context "valid object" do
      context "common objects" do
        let(:object) { FactoryGirl.build(:test_model_omnibus_ingest_object) }
        let(:apo) { FactoryGirl.create(:public_read_policy) }
        let(:parent) { FactoryGirl.create(:test_parent) }
        before do
          object.admin_policy = apo.pid
          object.parent = parent.pid
        end
        after do
          apo.destroy
          parent.destroy
        end
        it_behaves_like "a valid object"
      end
      context "target object" do
        let(:object) { FactoryGirl.build(:target_ingest_object) }
        let(:collection) { FactoryGirl.create(:collection) }
        before { object.collection = collection.pid }
        after { collection.destroy }
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

    context "yaml operations" do
      let(:object) { FactoryGirl.build(:test_model_omnibus_ingest_object) }
      let(:expected_yaml) do
        "--- !ruby/object:DulHydra::BatchIngest::IngestObject\nidentifier: #{object.identifier}\nmodel: TestModelOmnibus\nlabel: Test Model Label\ndata:\n- :datastream_name: descMetadata\n  :payload: <dc xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><dcterms:title>Test\n    Object Title</dcterms:title></dc>\n  :payload_type: bytes\n- :datastream_name: digitizationGuide\n  :payload: /home/coblej/workspace/dul-hydra/spec/fixtures/batch_ingest/miscellaneous/metadata.xls\n  :payload_type: filename\n- :datastream_name: content\n  :payload: /home/coblej/workspace/dul-hydra/spec/fixtures/batch_ingest/miscellaneous/id001.tif\n  :payload_type: filename\n"
      end
      context "to yaml" do
        it "should produce the appropriate yaml" do
          expect(object.to_yaml).to eq(expected_yaml)
        end
      end
      context "from_yaml" do
        it "should produce the appropriate object" do
          expect(IngestObject.from_yaml(expected_yaml)).to eq(object)
        end
      end
      context "yaml file operations" do
        before { @tmpdir = Dir.mktmpdir("dul_hydra_test") }
        after { FileUtils.remove_dir @tmpdir }
        context "write yaml file" do
          before do
            object.write_to_yaml_file(File.join(@tmpdir, "#{object.identifier}.yml"))
            @yaml_file = File.open(File.join(@tmpdir, "#{object.identifier}.yml")) { |f| f.read }
          end
          it "should produce the appropriate file" do
            FileUtils.compare_stream(StringIO.new(object.to_yaml), StringIO.new(@yaml_file)).should be_true
          end
        end
        context "read yaml file" do
          before do
            object.write_to_yaml_file(File.join(@tmpdir, "#{object.identifier}.yml"))
            @new_object = IngestObject.read_from_yaml_file(File.join(@tmpdir, "#{object.identifier}.yml"))
          end
          it "should produce the appropriate object" do
            expect(@new_object).to eq(object)
          end
        end
      end
    end
  
  end

end