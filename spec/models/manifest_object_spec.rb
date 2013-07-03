require 'spec_helper'

module DulHydra::Batch::Models

  describe "ManifestObject" do
  
    shared_examples "a valid manifest object" do
      it "should be valid" do
        expect(manifest_object.validate).to be_empty
      end
    end
  
    shared_examples "an invalid manifest object" do
      it "should not be valid" do
        expect(manifest_object.validate).to include(error_message)
      end
    end
  
    context "validate" do
      let(:manifest) { Manifest.new() }
      let(:manifest_object) { ManifestObject.new({}, manifest) }
      let(:basepath) { File.join(File::SEPARATOR, 'tmp') }
      let(:identifier) { 'id001001' }
      let(:model) { 'TestModel' }
      before do
        manifest.manifest_hash['basepath'] = basepath
        manifest_object.object_hash['identifier'] = identifier
        manifest_object.object_hash['model'] = model
      end
      context "valid" do
        it_behaves_like "a valid manifest object"
      end
      context "invalid" do
        context "identifier missing" do
          let(:error_message) { I18n.t('batch.manifest_object.errors.identifier_missing') }
          before { manifest_object.object_hash['identifier'] = nil }
          it_behaves_like "an invalid manifest object"
        end
        context "model" do
          context "missing" do
            let(:error_message) { I18n.t('batch.manifest_object.errors.model_missing', :identifier => identifier) }
            before { manifest_object.object_hash['model'] = nil }
            it_behaves_like "an invalid manifest object"
          end
          context "invalid" do
            let(:badmodel) { 'BadModel' }
            let(:error_message) { I18n.t('batch.manifest_object.errors.model_invalid', :identifier => identifier, :model => badmodel) }
            before { manifest_object.object_hash['model'] = badmodel }
            it_behaves_like "an invalid manifest object"
          end
        end
        context "keys" do
          let(:badkey) { "badkey" }
          let(:value) { "some_value" }
          context "invalid manifest object key" do
            let(:error_message) { I18n.t('batch.manifest_object.errors.invalid_key', :identifier => identifier, :key => badkey) }
            before { manifest_object.object_hash[badkey] = value }
            it_behaves_like "an invalid manifest object"
          end
          context "invalid manifest object sublevel key" do
            let(:key) { ManifestObject::CHECKSUM }
            let(:error_message) { I18n.t('batch.manifest_object.errors.invalid_subkey', :identifier => identifier, :key => key, :subkey => badkey) }
            before { manifest_object.object_hash[key] = { badkey => value } }
            it_behaves_like "an invalid manifest object"
          end
        end
        context "datastreams" do
          context "datastream list" do
            let(:key) { ManifestObject::DATASTREAMS }
            let(:bad_datastream_name) { "badDatastreamName" }
            let(:error_message) { I18n.t('batch.manifest_object.errors.datastream_name_invalid', :identifier => identifier, :name => bad_datastream_name) }
            before { manifest_object.object_hash[key] = [ bad_datastream_name ] }
            it_behaves_like "an invalid manifest object"
          end
          context "datastream filepath" do
            let(:key1) { ManifestObject::DATASTREAMS }
            let(:key2) { DulHydra::Datastreams::DESC_METADATA }
            let(:bad_location) { File.join(File::SEPARATOR, 'tmp', 'unreadable','filepath', 'metadata.xml') }
            let(:error_message) { I18n.t('batch.manifest_object.errors.datastream_filepath_error', :identifier => identifier, :datastream => key2, :filepath => bad_location) }
            before do
              manifest_object.object_hash[key1] = [ DulHydra::Datastreams::DESC_METADATA ]
              manifest_object.object_hash[key2] = bad_location
            end
            it_behaves_like "an invalid manifest object"
          end
        end
        context "checksum type" do
          let(:key) { Manifest::CHECKSUM }
          let(:bad_checksum_type) { "BAD-9999" }
          let(:error_message) { I18n.t('batch.manifest_object.errors.checksum_type_invalid', :identifier => identifier, :type => bad_checksum_type) }
          before { manifest_object.object_hash[key] = { Manifest::TYPE => bad_checksum_type } }
          it_behaves_like "an invalid manifest object"
        end
        context "relationships" do
          context "pid" do
            context "object not in repository" do
              let(:key) { BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY }
              let(:pid) { "duke-apo:adminPolicy" }
              let(:error_message) { I18n.t('batch.manifest_object.errors.relationship_object_not_found', :identifier => identifier, :relationship => key, :pid => pid) }
              before { manifest_object.object_hash[key] = pid }
              it_behaves_like "an invalid manifest object"
            end
            context "repository object not correct model" do
              let(:model) { "Item" }
              let(:key) { BatchObjectRelationship::RELATIONSHIP_PARENT }
              let(:relationship_class) { "Collection" }
              let(:error_message) { I18n.t('batch.manifest_object.errors.relationship_object_class_mismatch', :identifier => identifier, :relationship => key, :exp_class => relationship_class, :actual_class => object.class) }
              let(:object) { FactoryGirl.create(:component) }
              before do
                manifest_object.object_hash[Manifest::MODEL] = model
                manifest_object.object_hash[key] = object.pid
              end
              after { object.destroy }
              it_behaves_like "an invalid manifest object"
            end
          end
          context "id" do
            let(:key) { BatchObjectRelationship::RELATIONSHIP_PARENT }
            let(:subkey) { ManifestObject::ID }
            let(:id) { "test001" }
            before { manifest_object.object_hash[key] = { subkey => id } }
            context "cannot determine pid" do
              let(:error_message) { I18n.t('batch.manifest_object.errors.relationship_object_pid_not_determined', :identifier => identifier, :relationship => key) }
              it_behaves_like "an invalid manifest object"
            end
            context "object not in repository" do
              let(:pid) { "test:not_there" }
              let(:error_message) { I18n.t('batch.manifest_object.errors.relationship_object_not_found', :identifier => identifier, :relationship => key, :pid => pid) }
              let!(:batch_object) { BatchObject.create(:identifier => id, :pid => pid) }
              before { manifest_object.object_hash[key] = { subkey => id } }
              after { batch_object.destroy }
              it_behaves_like "an invalid manifest object"
            end
            context "repository object not correct model" do
              let(:model) { "Item" }
              let(:relationship_class) { "Collection" }
              let(:error_message) { I18n.t('batch.manifest_object.errors.relationship_object_class_mismatch', :identifier => identifier, :relationship => key, :exp_class => relationship_class, :actual_class => object.class) }
              let(:object) { FactoryGirl.create(:component) }
              let!(:batch_object) { BatchObject.create(:identifier => object.identifier.first, :pid => object.pid) }
              before do
                manifest_object.object_hash[Manifest::MODEL] = model
                manifest_object.object_hash[key] = { subkey => object.identifier.first }
              end
              after { object.destroy }
              it_behaves_like "an invalid manifest object"
            end
          end
        end
      end
    end
  
    context "batch" do
      let(:manifest) { Manifest.new }
      let(:manifest_object) { ManifestObject.new({}, manifest) }
      it "should return the batch specified in the manifest" do
        expect(manifest_object.batch).to eq(manifest.batch)
      end
    end
  
    context "checksum" do
      context "in object" do
        let(:manifest) { Manifest.new }
        let(:manifest_object) { ManifestObject.new({}, manifest) }
        context "in object 'checksum'" do
          before { manifest_object.object_hash["checksum"] = "abcdef" }
          it "should return the object 'checksum'" do
            expect(manifest_object.checksum?).to be_true
            expect(manifest_object.checksum).to eq("abcdef")
          end
        end
        context "in object 'checksum''value'" do
          before { manifest_object.object_hash["checksum"] = { "value" => "123456" } }
          it "should return the object 'checksum''value'" do
            expect(manifest_object.checksum?).to be_true
            expect(manifest_object.checksum).to eq("123456")
          end
        end
      end
      context "in manifest 'checksum' file" do
        let(:manifest) { Manifest.new(File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'manifests', 'manifest_with_files.yml')) }
        let(:manifest_object) { ManifestObject.new({ "identifier" => "id001" }, manifest) }
        it "should return the checksum from manifest 'checksum' file" do
          expect(manifest_object.checksum?).to be_true
          expect(manifest_object.checksum).to eq("120ad0814f207c45d968b05f7435034ecfee8ac1a0958cd984a070dad31f66f3")
        end
      end
      context "no checksum" do
        let(:manifest) { Manifest.new }
        let(:manifest_object) { ManifestObject.new({}, manifest) }
        it "should return nil" do
          expect(manifest_object.checksum?).to be_false
          expect(manifest_object.checksum).to be_nil
        end
      end
    end
  
    context "checksum type" do
      context "in object" do
        let(:manifest) { Manifest.new }
        let(:manifest_object) { ManifestObject.new({}, manifest) }
        context "in object 'checksum''type'" do
          before { manifest_object.object_hash["checksum"] = { "type" => "SHA-1" } }
          it "should return the object 'checksum''type'" do
            expect(manifest_object.checksum_type?).to be_true
            expect(manifest_object.checksum_type).to eq("SHA-1")
          end
        end
      end
      context "in manifest 'checksum' file" do
        let(:manifest) { Manifest.new(File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'manifests', 'manifest_with_files.yml')) }
        let(:manifest_object) { ManifestObject.new({ "identifier" => "id001" }, manifest) }
        it "should return the checksum from manifest 'checksum' file" do
          expect(manifest_object.checksum_type?).to be_true
          expect(manifest_object.checksum_type).to eq("SHA-256")
        end
      end
      context "no checksum type" do
        let(:manifest) { Manifest.new }
        let(:manifest_object) { ManifestObject.new({}, manifest) }
        it "should return nil" do
          expect(manifest_object.checksum_type?).to be_false
          expect(manifest_object.checksum_type).to be_nil
        end
      end
    end
  
    context "datastream filepath" do
      let(:manifest) { Manifest.new() }
      let(:manifest_object) { ManifestObject.new({}, manifest) }
      context "in object"do
        context "absolute filepath" do
          before { manifest_object.object_hash["foo"] = "/a/b/c.xml" }
          it "should return the absolute filepath" do
            expect(manifest_object.datastream_filepath("foo")).to eq("/a/b/c.xml")
          end
        end
        context "relative filepath" do
          before { manifest_object.object_hash["foo"] = "a/b/c.xml" }
          context "manifest has datastream location" do
            before do
              manifest.manifest_hash["foo"] = { "location" => "/x/y/" }
            end
            it "should return the object relative filepath appended to the manifest location" do
              expect(manifest_object.datastream_filepath("foo")).to eq("/x/y/a/b/c.xml")
            end
          end
          context "manifest does not have datastream location" do
            before do
              manifest.manifest_hash["basepath"] = "/e/f/"
            end
            it "should return the object relative filepath appended to the canonical location" do
              expect(manifest_object.datastream_filepath("foo")).to eq("/e/f/foo/a/b/c.xml")
            end
          end
        end
      end
      context "not in object" do
        before { manifest_object.object_hash["identifier"] = "id99" }
        context "manifest has datastream location" do
          before do
            manifest.manifest_hash["foo"] = { "location" => "/x/y/", "extension" => ".xls" }
          end
          it "should return the canonical filename appended to the manifest location" do
            expect(manifest_object.datastream_filepath("foo")).to eq("/x/y/id99.xls")
          end
        end
        context "manifest does not have datastream location" do
          before do
            manifest.manifest_hash["basepath"] = "/e/f/"
          end
          it "should return the canonical location and filename" do
            expect(manifest_object.datastream_filepath("foo")).to eq("/e/f/foo/id99.xml")
          end
        end
      end
    end
  
    context "datastreams" do
      let(:manifest) { Manifest.new() }
      let(:manifest_object) { ManifestObject.new({}, manifest) }
      context "object has datastreams" do
        before do
          manifest.manifest_hash["datastreams"] = [ "e", "f" ]
          manifest_object.object_hash["datastreams"] = [ "a", "b", "c"]
        end
        it "should return the object datastreams" do
          expect(manifest_object.datastreams).to eq([ "a", "b", "c" ])
        end
      end
      context "object does not have datastreams but manifest does" do
        before do
          manifest.manifest_hash["datastreams"] = [ "e", "f" ]
        end
        it "should return the manifest datastreams" do
          expect(manifest_object.datastreams).to eq([ "e", "f" ])
        end
      end
      context "neither object nor manifest have datastreams" do
        it "should return nil" do
          expect(manifest_object.datastreams).to be_nil
        end
      end
    end
  
    context "key identifier" do
      let(:manifest) { Manifest.new() }
      let(:manifest_object) { ManifestObject.new({}, manifest) }
      context "object identifier is a string" do
        before { manifest_object.object_hash["identifier"] = "id1234" }
        it "should return the identifier" do
          expect(manifest_object.key_identifier).to eq("id1234")
        end
      end
      context "object identifier is a list" do
        before { manifest_object.object_hash["identifier"] = [ "id1234", "id5678" ] }
        it "should return the first identifier" do
          expect(manifest_object.key_identifier).to eq("id1234")
        end
      end
      context "object identifier missing" do
        it "should return nil" do
          expect(manifest_object.key_identifier).to be_nil
        end
      end
    end
  
    context "label / model" do
      let(:manifest) { Manifest.new }
      let(:manifest_object) { ManifestObject.new({}, manifest) }
      context "label / model in object" do
        before do
          manifest.manifest_hash["label"] = "Manifest Label"
          manifest.manifest_hash["model"] = "ManifestModel"
          manifest_object.object_hash["label"] = "Object Label"
          manifest_object.object_hash["model"] = "ObjectModel"
        end
        it "should return the label / model specified in the object" do
          expect(manifest_object.label).to eq("Object Label")
          expect(manifest_object.model).to eq("ObjectModel")
        end
      end
      context "label / model not in object but in manifest" do
        before do
          manifest.manifest_hash["label"] = "Manifest Label"
          manifest.manifest_hash["model"] = "ManifestModel"
        end
        it "should return the label / model specified in the manifest" do
          expect(manifest_object.model).to eq("ManifestModel")
        end
      end
      context "no label / model" do
        it "should return nil" do
          expect(manifest_object.label).to be_nil
          expect(manifest_object.model).to be_nil
        end
      end
    end
  
    context "relationship" do
      let(:relationship) { "test_relationship" }
      let(:manifest) { Manifest.new }
      let(:manifest_object) { ManifestObject.new({}, manifest) }
      context "relationship in object" do
        context "explicit pid" do
          let(:manifest_relationship_pid) { "test:1234" }
          let(:object_relationship_pid) { "test:5678" }
          before { manifest.manifest_hash[relationship] = manifest_relationship_pid }
          context "bare pid" do
            before { manifest_object.object_hash[relationship] = object_relationship_pid }
            it "should return the object pid" do
              expect(manifest_object.has_relationship?(relationship)).to be_true
              expect(manifest_object.relationship_pid(relationship)).to eq(object_relationship_pid)
            end
          end
          context "pid in 'pid'" do
            before { manifest_object.object_hash[relationship] = { "pid" => object_relationship_pid } }
            it "should return the object pid" do
              expect(manifest_object.has_relationship?(relationship)).to be_true
              expect(manifest_object.relationship_pid(relationship)).to eq(object_relationship_pid)
            end
          end
        end
        context "id" do
          let(:relationship_id) { "id001" }
          let(:relationship_id_length) { 5 }
          let(:distractor_id) { "id002" }
          let(:distractor_id_length) { 4 }
          let(:pid_1) { "test:1234" }
          let(:pid_2) { "test:5678" }
          let(:manifest) { Manifest.new }
          let(:manifest_object) { ManifestObject.new({ "identifier" => "id00100020" }, manifest) }
          let(:batch1) { Batch.create! }
          let(:batch2) { Batch.create! }
          before do
            @batch_object_a = BatchObject.create!(:batch_id => batch1.id, :identifier => relationship_id, :pid => pid_1)
            @batch_object_b = BatchObject.create!(:batch_id => batch2.id, :identifier => relationship_id, :pid => pid_2)
          end
          context "batchid" do
            context "explicit id" do
              before do
                manifest.manifest_hash[relationship] = { "id" => relationship_id, "batchid" => batch2.id }
                manifest_object.object_hash[relationship] = { "id" => relationship_id, "batchid" => batch1.id }
              end
              it "should return the correct pid" do
                expect(manifest_object.relationship_pid(relationship)).to eq(pid_1)
              end
            end
            context "autoidlength" do
              before do
                manifest.manifest_hash[relationship] = { "autoidlength" => relationship_id_length, "batchid" => batch2.id }
                manifest_object.object_hash[relationship] = { "autoidlength" => relationship_id_length, "batchid" => batch1.id }
              end
              it "should return the correct pid" do
                expect(manifest_object.relationship_pid(relationship)).to eq(pid_1)
              end
            end
          end
          context "no batchid" do
            context "explicit id" do
              before do
                manifest.manifest_hash[relationship] = { "id" => distractor_id }
                manifest_object.object_hash[relationship] = { "id" => relationship_id }
              end
              it "should return the correct pid" do
                expect(manifest_object.relationship_pid(relationship)).to eq(pid_2)
              end
            end
            context "autoidlength" do
              before do
                manifest.manifest_hash[relationship] = { "autoidlength" => distractor_id_length }
                manifest_object.object_hash[relationship] = { "autoidlength" => relationship_id_length }
              end
              it "should return the correct pid" do
                expect(manifest_object.relationship_pid(relationship)).to eq(pid_2)
              end
            end
          end
        end
      end
      context "relationship in manifest" do
        context "explicit pid" do
          let(:relationship_pid) { "test:1234" }
          context "bare pid" do
            before { manifest.manifest_hash[relationship] = relationship_pid }
            it "should return the manifest pid" do
              expect(manifest_object.has_relationship?(relationship)).to be_true
              expect(manifest_object.relationship_pid(relationship)).to eq(relationship_pid)
            end
          end
          context "pid in 'pid'" do
            before { manifest.manifest_hash[relationship] = { "pid" => relationship_pid } }
            it "should return the manifest pid" do
              expect(manifest_object.has_relationship?(relationship)).to be_true
              expect(manifest_object.relationship_pid(relationship)).to eq(relationship_pid)
            end
          end
        end
        context "id" do
          let(:relationship_id) { "id001" }
          let(:relationship_id_length) { 5 }
          let(:pid_1) { "test:1234" }
          let(:pid_2) { "test:5678" }
          let(:manifest) { Manifest.new }
          let(:manifest_object) { ManifestObject.new({ "identifier" => "id00100020" }, manifest) }
          let(:batch1) { Batch.create! }
          let(:batch2) { Batch.create! }
          before do
            @batch_object_a = BatchObject.create!(:batch_id => batch1.id, :identifier => relationship_id, :pid => pid_1)
            @batch_object_b = BatchObject.create!(:batch_id => batch2.id, :identifier => relationship_id, :pid => pid_2)
          end
          context "batchid" do
            context "explicit id" do
              before { manifest.manifest_hash[relationship] = { "id" => relationship_id, "batchid" => batch1.id } }
              it "should return the correct pid" do
                expect(manifest_object.relationship_pid(relationship)).to eq(pid_1)
              end
            end
            context "autoidlength" do
              before { manifest.manifest_hash[relationship] = { "autoidlength" => relationship_id_length, "batchid" => batch1.id } }
              it "should return the correct pid" do
                expect(manifest_object.relationship_pid(relationship)).to eq(pid_1)
              end
            end
          end
          context "no batchid" do
            context "explicit id" do
              before { manifest.manifest_hash[relationship] = { "id" => relationship_id } }
              it "should return the correct pid" do
                expect(manifest_object.relationship_pid(relationship)).to eq(pid_2)
              end
            end
            context "autoidlength" do
              before { manifest.manifest_hash[relationship] = { "autoidlength" => relationship_id_length } }
              it "should return the correct pid" do
                expect(manifest_object.relationship_pid(relationship)).to eq(pid_2)
              end
            end
          end
        end
      end
      context "no relationship" do
        it "should return false / nil" do
          expect(manifest_object.has_relationship?(relationship)).to be_false
          expect(manifest_object.relationship_pid(relationship)).to be_nil
        end
      end
    end
  
  end

end