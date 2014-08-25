require 'spec_helper'

module DulHydra::Batch::Models

  describe Manifest, type: :model, batch: true do
  
    shared_examples "a valid manifest" do
      it "should be valid" do
        expect(manifest.validate).to be_empty
      end
    end
  
    shared_examples "an invalid manifest" do
      it "should not be valid" do
        expect(manifest.validate).to include(error_message)
      end
    end
  
    context "validate" do
      let(:collection_pid) { "test:1" }
      context "valid" do
        let!(:collection) { Collection.create(:pid => collection_pid, :title => ["Test Collection"]) }
        context "manifest with files" do
          let(:manifest) { Manifest.new(File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'manifests', 'manifest_with_files.yml')) }
          before { manifest.manifest_hash['basepath'] = File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous') }
          it_behaves_like "a valid manifest"
        end
        context "manifest with parent autoidlength" do
          let(:manifest) { Manifest.new }
          before do
            manifest.manifest_hash[Manifest::BASEPATH] = "/tmp"
            manifest.manifest_hash[BatchObjectRelationship::RELATIONSHIP_PARENT] = { Manifest::AUTOIDLENGTH => 5 }
          end
          it_behaves_like "a valid manifest"
        end
      end
      context "invalid" do
        let(:manifest) { Manifest.new }
        context "invalid model" do
          let(:key) { Manifest::MODEL }
          let(:model) { "BadModel" }
          let(:error_message) { I18n.t('batch.manifest.errors.model_invalid', :model => manifest.model) }
          before { manifest.manifest_hash[key] = model }
          it_behaves_like "an invalid manifest"
        end
        context "keys" do
          let(:badkey) { "badkey" }
          let(:value) { "some_value" }
          context "invalid manifest level key" do
            let(:error_message) { I18n.t('batch.manifest.errors.invalid_key', :key => badkey) }
            before { manifest.manifest_hash[badkey] = value }
            it_behaves_like "an invalid manifest"
          end
          context "invalid manifest sublevel key" do
            let(:key) { DulHydra::Datastreams::DESC_METADATA }
            let(:error_message) { I18n.t('batch.manifest.errors.invalid_subkey', :key => key, :subkey => badkey) }
            before { manifest.manifest_hash[key] = { badkey => value } }
            it_behaves_like "an invalid manifest"
          end
        end
        context "datastreams" do
          context "datastream list" do
            let(:key) { Manifest::DATASTREAMS }
            let(:bad_datastream_name) { "badDatastreamName" }
            let(:error_message) { I18n.t('batch.manifest.errors.datastream_name_invalid', :name => bad_datastream_name) }
            before { manifest.manifest_hash[key] = [ bad_datastream_name ] }
            it_behaves_like "an invalid manifest"
          end
          context "datastream filepath" do
            let(:key) { DulHydra::Datastreams::DESC_METADATA }
            let(:bad_location) { File.join(File::SEPARATOR, 'tmp', 'unreadable','filepath') }
            let(:error_message) { I18n.t('batch.manifest.errors.datastream_filepath_error', :datastream => key, :filepath => bad_location) }
            before { manifest.manifest_hash[key] = { Manifest::LOCATION => bad_location } }
            it_behaves_like "an invalid manifest"
          end
        end
        context "checksums" do
          let(:key) { Manifest::CHECKSUM }
          context "checksum type" do
            let(:bad_checksum_type) { "BAD-9999" }
            let(:error_message) { I18n.t('batch.manifest.errors.checksum_type_invalid', :type => bad_checksum_type) }
            before { manifest.manifest_hash[key] = { Manifest::TYPE => bad_checksum_type } }
            it_behaves_like "an invalid manifest"
          end
          context "checksum file" do
            context "invalid location" do
              let(:location) { "/tmp/nonexistent/file/checksums.xml" }
              let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_error', :file => location) }
              before { manifest.manifest_hash[key] = { Manifest::LOCATION => location } }
              it_behaves_like "an invalid manifest"
            end
            context "not XML document" do
              let(:file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'yaml_hash.txt') }
              let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_not_xml', :file => file) }
              before { manifest.manifest_hash[key] = { Manifest::LOCATION => file } }
              it_behaves_like "an invalid manifest"
            end
            context "node_xpath" do
              context "not specified and default xpath absent" do
                let(:file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'metadata.xml') }
                let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_node_error', :node => manifest.checksum_node_xpath, :file => file) }
                before { manifest.manifest_hash[key] = { Manifest::LOCATION => file } }
                it_behaves_like "an invalid manifest"
              end
              context "specified but absent" do
                let(:file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'checksums.xml') }
                let(:node_xpath) { "/foo/bar" }
                let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_node_error', :node => manifest.checksum_node_xpath, :file => file) }
                before { manifest.manifest_hash[key] = { Manifest::LOCATION => file, Manifest::NODE_XPATH => node_xpath } }
                it_behaves_like "an invalid manifest"
              end
            end
            context "identifier_element" do
              context "not specified and default xpath absent" do
                let(:file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'incorrect_checksums.xml') }
                let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_node_error', :node => manifest.checksum_identifier_element, :file => file) }
                before { manifest.manifest_hash[key] = { Manifest::LOCATION => file } }
                it_behaves_like "an invalid manifest"
              end
              context "specified but absent" do
                let(:file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'checksums.xml') }
                let(:identifier_element) { "bogus" }
                let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_node_error', :node => manifest.checksum_identifier_element, :file => file) }
                before { manifest.manifest_hash[key] = { Manifest::LOCATION => file, Manifest::IDENTIFIER_ELEMENT => identifier_element } }
                it_behaves_like "an invalid manifest"
              end
            end
            context "type xpath" do
              context "not specified and default type xpath absent" do
                let(:file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'checksums_bad_elements.xml') }
                let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_node_error', :node => manifest.checksum_type_xpath, :file => file) }
                before { manifest.manifest_hash[key] = { Manifest::LOCATION => file } }
                it_behaves_like "an invalid manifest"
              end
              context "specified but absent" do
                let(:file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'checksums.xml') }
                let(:type_xpath) { "bogus" }
                let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_node_error', :node => manifest.checksum_type_xpath, :file => file) }
                before { manifest.manifest_hash[key] = { Manifest::LOCATION => file, Manifest::TYPE_XPATH => type_xpath } }
                it_behaves_like "an invalid manifest"
              end
            end
            context "value xpath" do
              context "not specified and default value xpath absent" do
                let(:file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'checksums_bad_elements.xml') }
                let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_node_error', :node => manifest.checksum_value_xpath, :file => file) }
                before { manifest.manifest_hash[key] = { Manifest::LOCATION => file } }
                it_behaves_like "an invalid manifest"
              end
              context "specified but absent" do
                let(:file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'checksums_bad_elements.xml') }
                let(:value_xpath) { "bogus" }
                let(:error_message) { I18n.t('batch.manifest.errors.checksum_file_node_error', :node => manifest.checksum_value_xpath, :file => file) }
                before { manifest.manifest_hash[key] = { Manifest::LOCATION => file, Manifest::VALUE_XPATH => value_xpath } }
                it_behaves_like "an invalid manifest"
              end
            end
          end
        end
        context "relationships" do
          context "pid" do
            context "object not in repository" do
              let(:key) { BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY }
              let(:pid) { "test:1" }
              let(:error_message) { I18n.t('batch.manifest.errors.relationship_object_not_found', :relationship => key, :pid => pid) }
              before { manifest.manifest_hash[key] = pid }
              it_behaves_like "an invalid manifest"
            end
            context "repository object not correct model" do
              let(:model) { "Item" }
              let(:key) { BatchObjectRelationship::RELATIONSHIP_PARENT }
              let(:relationship_class) { "Collection" }
              let(:error_message) { I18n.t('batch.manifest.errors.relationship_object_class_mismatch', :relationship => key, :exp_class => relationship_class, :actual_class => object.class) }
              let(:object) { FactoryGirl.create(:component) }
              before do
                manifest.manifest_hash[Manifest::MODEL] = model
                manifest.manifest_hash[key] = object.pid
              end
              it_behaves_like "an invalid manifest"
            end
          end
          context "id" do
            let(:key) { BatchObjectRelationship::RELATIONSHIP_PARENT }
            let(:subkey) { Manifest::ID }
            let(:id) { "test001" }
            before { manifest.manifest_hash[key] = { subkey => id } }
            context "cannot determine pid" do
              let(:error_message) { I18n.t('batch.manifest.errors.relationship_object_pid_not_determined', :relationship => key) }
              it_behaves_like "an invalid manifest"
            end
            context "object not in repository" do
              let(:pid) { "test:not_there" }
              let(:error_message) { I18n.t('batch.manifest.errors.relationship_object_not_found', :relationship => key, :pid => pid) }
              let!(:batch_object) { BatchObject.create(:identifier => id, :pid => pid) }
              before { manifest.manifest_hash[key] = { subkey => id } }
              it_behaves_like "an invalid manifest"
            end
            context "repository object not correct model" do
              let(:model) { "Item" }
              let(:relationship_class) { "Collection" }
              let(:error_message) { I18n.t('batch.manifest.errors.relationship_object_class_mismatch', :relationship => key, :exp_class => relationship_class, :actual_class => object.class) }
              let(:object) { FactoryGirl.create(:component) }
              let!(:batch_object) { BatchObject.create(:identifier => object.identifier.first, :pid => object.pid) }
              before do
                manifest.manifest_hash[Manifest::MODEL] = model
                manifest.manifest_hash[key] = { subkey => object.identifier.first }
              end
              it_behaves_like "an invalid manifest"
            end
          end
        end
      end
    end
  
    context "load yaml manifest file" do
      let(:manifest) { Manifest.new(File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'yaml.yml')) }
      let(:yaml_hash) { eval File.open(File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'yaml_hash.txt')) { |f| f.read } }
      it "should lead the YAML file" do
        expect(manifest.manifest_hash).to be_a_kind_of(Hash)
        expect(manifest.manifest_hash).to eq(yaml_hash)
      end
    end
  
    context "methods" do
      let(:manifest) { Manifest.new }
      context "basepath, label, model" do
        let(:basepath) { "basePath" }
        let(:label) { "expectedLabel" }
        let(:model) { "modelToUse" }
        before { manifest.manifest_hash = HashWithIndifferentAccess.new("basepath" => basepath, "label" => label, "model" => model) }
        it "should return the correct basepath, label, and model" do
          expect(manifest.basepath).to eq(basepath)
          expect(manifest.label).to eq(label)
          expect(manifest.model).to eq(model)
        end
      end
      context "batch" do
        context "new batch" do
          let(:user) { FactoryGirl.create(:user) }
          let(:batch_name) { "New Batch Name #{Time.now.to_s}" }
          let(:batch_description) { "New Batch Description #{Time.now.to_s}" }
          before do
            manifest.manifest_hash = { "batch" =>
                { "name" => batch_name,
                  "description" => batch_description,
                  "user_email" => user.email
                }
              }
          end
          it "should return the correct values" do
            expect(manifest.batch_name).to eq(batch_name)
            expect(manifest.batch_description).to eq(batch_description)
            expect(manifest.batch_user_email).to eq(user.email)
          end
        end
        context "existing batch" do
          let(:batch) { Batch.create }
          before { manifest.manifest_hash = { "batch" => { "id" => batch.id } } }
          it "should return the correct value" do
            expect(manifest.batch_id).to eq(batch.id)
          end
        end
      end
      context "checksums" do
        context "identifier element, node xpath, type, type xpath, value xpath" do
          context "provided" do
            let(:identifier_element) { "identifierElement" }
            let(:node_xpath) { "/node/xpath" }
            let(:type) { "FOO-1" }
            let(:type_xpath) { "the_type" }
            let(:value_xpath) { "the_value" }
            before do
              manifest.manifest_hash = HashWithIndifferentAccess.new("checksum" => { "identifier_element" =>  identifier_element,
                                                                                   "node_xpath" => node_xpath,
                                                                                   "type" => type,
                                                                                   "type_xpath" => type_xpath,
                                                                                   "value_xpath" => value_xpath
                                                                                 } )
            end
            it "should use the provided values" do
              expect(manifest.checksum_identifier_element).to eq(identifier_element)
              expect(manifest.checksum_node_xpath).to eq(node_xpath)
              expect(manifest.checksum_type?).to be_truthy
              expect(manifest.checksum_type).to eq(type)
              expect(manifest.checksum_type_xpath).to eq(type_xpath)
              expect(manifest.checksum_value_xpath).to eq(value_xpath)
            end
          end
          context "not provided" do
            it "should use the default values if any" do
              expect(manifest.checksum_identifier_element).to eq("id")
              expect(manifest.checksum_node_xpath).to eq("/checksums/checksum")
              expect(manifest.checksum_type?).to be_falsey
              expect(manifest.checksum_type).to be_nil
              expect(manifest.checksum_type_xpath).to eq("type")
              expect(manifest.checksum_value_xpath).to eq("value")
            end
          end
        end
        context "checksums XML document" do
          let(:checksums_filepath) { File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'checksums.xml') }
          let(:checksums_document) { File.open(checksums_filepath) { |f| Nokogiri.XML(f) } }
          before { manifest.manifest_hash = HashWithIndifferentAccess.new("checksum" => { "location" => checksums_filepath }) }
          it "should open the XML document" do
            expect(manifest.checksums?).to be_truthy
            expect(manifest.checksums).to be_equivalent_to(checksums_document)
          end
        end
      end
      context "datastreams" do
        context "datastreams list" do
          let(:datastream_names) { [ "DS1", "DS2", "DS3" ] }
          before { manifest.manifest_hash = HashWithIndifferentAccess.new("datastreams" => datastream_names) }
          it "should return the list of datastream names" do
            expect(manifest.datastreams.size).to eq(datastream_names.size)
            manifest.datastreams.each { |datastream| expect(datastream_names).to include(datastream) }
          end
        end
        context "datastream extension, datastream location" do
          let(:datastream_name) { "fooDatastream" }
          let(:extension) { ".foo" }
          let(:location) { "/tmp" }
          context "provided" do
            before { manifest.manifest_hash = HashWithIndifferentAccess.new(datastream_name => { "extension" => extension, "location" => location }) }
            it "should use the provided values" do
              expect(manifest.datastream_extension(datastream_name)).to eq(extension)
              expect(manifest.datastream_location(datastream_name)).to eq(location)
            end
          end
          context "not provided" do
            it "should return nil" do
              expect(manifest.datastream_extension(datastream_name)).to be_nil
              expect(manifest.datastream_location(datastream_name)).to be_nil
            end
          end
        end
      end
      context "objects" do
        let(:object1) { HashWithIndifferentAccess.new( "identifier" => "id001" ) }
        let(:object2) { HashWithIndifferentAccess.new( "identifier" => "id002" ) }
        let(:object3) { HashWithIndifferentAccess.new( "identifier" => "id003" ) }
        let(:objects) { [ object1, object2, object3 ] }
        before { manifest.manifest_hash = HashWithIndifferentAccess.new( "objects" => objects ) }
        it "should return manifest objects" do
          expect(manifest.objects.size).to eq(objects.size)
          manifest.objects.each { |obj| expect(["id001", "id002", "id003"]).to include(obj.key_identifier) }
        end
      end
      context "relationships" do
        context "relationship autoidlength, relationship id, relationship pid" do
          let(:relationship_name) { "foo_relationship" }
          let(:autoidlength) { 5 }
          let(:id) { "id123" }
          let(:pid) { "foo:1234" }
          context "provided" do
            before { manifest.manifest_hash = HashWithIndifferentAccess.new(relationship_name => { "autoidlength" => autoidlength, "id" => id, "pid" => pid }) }
            it "should use the provided values" do
              expect(manifest.relationship_autoidlength(relationship_name)).to eq(autoidlength)
              expect(manifest.relationship_id(relationship_name)).to eq(id)
              expect(manifest.relationship_pid(relationship_name)).to eq(pid)
            end
          end
          context "not provided" do
            it "should return nil" do
              expect(manifest.relationship_autoidlength(relationship_name)).to be_nil
              expect(manifest.relationship_id(relationship_name)).to be_nil
              expect(manifest.relationship_pid(relationship_name)).to be_nil
            end
          end
        end
      end
    end
  
  end

end
