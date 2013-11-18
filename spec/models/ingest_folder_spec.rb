require 'spec_helper'

shared_examples "an invalid ingest folder" do
  it "should not be valid" do
    expect(ingest_folder).to_not be_valid
    expect(ingest_folder.errors).to have_key(error_field)
  end  
end

describe IngestFolder do

  let(:ingest_folder) { FactoryGirl.build(:ingest_folder, :user => user) }
  let(:user) { FactoryGirl.create(:user) }
  before do
    File.stub(:readable?).and_return(true)
    IngestFolder.stub(:permitted_folders).with(user).and_return(["/base/path/"])
  end
  after do
    user.destroy
  end
  context "validation" do
    before do
      File.stub(:readable?).with("/base/path/unreadable/").and_return(false)
      File.stub(:readable?).with("/base/path/subpath/unreadable.txt").and_return(false)      
    end
    it "should have a valid factory" do
      expect(ingest_folder).to be_valid
    end
    context "base path not permitted" do
      let(:error_field) { :base_path }
      before { ingest_folder.base_path = "/forbidden/path/" }
      it_behaves_like "an invalid ingest folder"
    end
    context "subpath missing" do
      let(:error_field) { :sub_path }      
      before { ingest_folder.sub_path = "" }
      it_behaves_like "an invalid ingest folder"
    end
    context "subpath readable" do
      let(:error_field) { :sub_path }
      before { ingest_folder.sub_path = "unreadable/" }
      it_behaves_like "an invalid ingest folder"
    end
    context "collection pid missing" do
      let(:error_field) { :collection_pid }
      before { ingest_folder.collection_pid = "" }
      it_behaves_like "an invalid ingest folder"
    end
    context "admin policy pid missing" do
      let(:error_field) { :admin_policy_pid }
      before { ingest_folder.admin_policy_pid = "" }
      it_behaves_like "an invalid ingest folder"
    end
    context "checksum file unreadable" do
      let(:error_field) { :checksum_file }
      before { ingest_folder.checksum_file = "/subpath/unreadable.txt" }
      it_behaves_like "an invalid ingest folder"
    end
  end
  context "operations" do
    let(:ingest_folder) { FactoryGirl.build(:ingest_folder, :user => user) }
    before do
      Dir.stub(:foreach).with("/base/path/subpath/").and_return(
        Enumerator.new { |y| y << "Thumbs.db" << "file01001.tif" << "file01002.tif" << "pdf" << "targets" }
      )
      Dir.stub(:foreach).with("/base/path/subpath/pdf").and_return(
        Enumerator.new { |y| y << "file01.pdf" }
      )
      Dir.stub(:foreach).with("/base/path/subpath/targets").and_return(
        Enumerator.new { |y| y << "Thumbs.db" << "T001.tiff" << "T002.tiff"}
      )
      File.stub(:directory?).and_return(false)
      File.stub(:directory?).with("/base/path/subpath/pdf").and_return(true)
      File.stub(:directory?).with("/base/path/subpath/targets").and_return(true)
    end
    context "scan" do
      let(:scan_results) { ingest_folder.scan }
      it "should report the correct scan results" do
        expect(scan_results.file_count).to eql(3)
        expect(scan_results.parent_count).to eql(1)
        expect(scan_results.target_count).to eql(2)
        expect(scan_results.excluded_files).to eql(["Thumbs.db", "targets/Thumbs.db"])
      end
    end
    context "procezz" do
      let(:objects) { {} }
      let(:dss) { {} }
      let(:rels) { {} }
      before do 
        ingest_folder.procezz
        user.batches.first.batch_objects.each do |obj|
          objects[obj.identifier] = obj
          obj.batch_object_datastreams.each { |ds| dss[obj.identifier] = { ds.name => ds } }
          obj.batch_object_relationships.each { |rel| rels[obj.identifier] = { rel.name => rel } }
        end
      end
      it "should create the correct batch objects" do
        expect(user.batches.count).to eql(1)
        expect(objects.fetch('f').model).to eql("Item")
        expect(objects.fetch('file01001').model).to eql(IngestFolder.default_file_model)
        expect(objects.fetch('file01002').model).to eql(IngestFolder.default_file_model)
        expect(objects.fetch('file01').model).to eql(IngestFolder.default_file_model)
        expect(objects.fetch('T001').model).to eql(IngestFolder.default_target_model)
        expect(objects.fetch('T002').model).to eql(IngestFolder.default_target_model)
        expect(dss.fetch('file01001').fetch('content').payload).to eql(File.join(ingest_folder.full_path, "file01001.tif"))
        expect(dss.fetch('file01002').fetch('content').payload).to eql(File.join(ingest_folder.full_path, "file01002.tif"))
        expect(dss.fetch('file01').fetch('content').payload).to eql(File.join(ingest_folder.full_path, "pdf/file01.pdf"))
        expect(dss.fetch('T001').fetch('content').payload).to eql(File.join(ingest_folder.full_path, "targets/T001.tiff"))
        expect(dss.fetch('T002').fetch('content').payload).to eql(File.join(ingest_folder.full_path, "targets/T002.tiff"))
        expect(rels.fetch('f').fetch('parent').object).to eql(ingest_folder.collection_pid)
        expect(rels.fetch('file01001').fetch('parent').object).to eql(objects.fetch('f').pid)
        expect(rels.fetch('file01002').fetch('parent').object).to eql(objects.fetch('f').pid)
        expect(rels.fetch('file01').fetch('parent').object).to eql(objects.fetch('f').pid)
        expect(rels.fetch('T001').fetch('collection').object).to eql(ingest_folder.collection_pid)
        expect(rels.fetch('T002').fetch('collection').object).to eql(ingest_folder.collection_pid)
      end
    end
  end

end
