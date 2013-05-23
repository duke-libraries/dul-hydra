require 'spec_helper'

describe "ManifestObject" do
  
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
  
  context "label" do
    let(:manifest) { Manifest.new }
    let(:manifest_object) { ManifestObject.new({}, manifest) }
    context "label in object" do
      before do
        manifest.manifest_hash["label"] = "Manifest Label"
        manifest_object.object_hash["label"] = "Object Label"
      end
      it "should return the batch specified in the object" do
        expect(manifest_object.label).to eq("Object Label")
      end
    end
    context "label not in object but in manifest" do
      before { manifest.manifest_hash["label"] = "Manifest Label" }
      it "should return the batch specified in the manifest" do
        expect(manifest_object.label).to eq("Manifest Label")
      end
    end
    context "no label" do
      it "should return the batch specified in the manifest" do
        expect(manifest_object.label).to be_nil
      end
    end
  end
  
  
end