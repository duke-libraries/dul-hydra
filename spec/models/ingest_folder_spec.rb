require 'spec_helper'

shared_examples "an invalid ingest folder" do
  it "should not be valid" do
    expect(ingest_folder).to_not be_valid
    expect(ingest_folder.errors).to have_key(error_field)
  end  
end

describe IngestFolder do

  let(:ingest_folder) { FactoryGirl.build(:ingest_folder, :user => user) }
  let(:mount_point_name) { "base" }
  let(:mount_point_path) { "/mount/" }
  let(:base_path) { File.join(mount_point_name, "base/path/") }
  let(:checksum_directory) { "/fixity/fedora_ingest/" }
  let(:checksum_type) { "checksum-type" }
  let(:user) { FactoryGirl.create(:user) }
  before do
    File.stub(:readable?).and_return(true)
    config = <<-EOS
    config:
        file_model: TestChild
        target_model: Target
        target_folder: targets
        checksum_file:
            location: #{checksum_directory}
            type: #{checksum_type}
        file_creators:
            ABC: Alpha Bravo Charlie
    files:
        mount_points:
            #{mount_point_name}: #{mount_point_path}
        permissions:
            #{user.user_key}:
            - #{mount_point_name}/path/
    EOS
    IngestFolder.stub(:load_configuration).and_return(YAML.load(config).with_indifferent_access)
  end
  after do
    ingest_folder.destroy
    user.destroy
  end
  context "initialization" do
    let(:ingest_folder) { IngestFolder.new }
    it "should set the checksum type to the default" do
      expect(ingest_folder.checksum_type).to eql(checksum_type)
    end
  end
  context "validation" do
    before do
      File.stub(:readable?).with("/mount/base/path/unreadable/").and_return(false)
      File.stub(:readable?).with(File.join(checksum_directory, "unreadable.txt")).and_return(false)      
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
      before do 
        ingest_folder.checksum_file = "unreadable.txt"
      end
      it_behaves_like "an invalid ingest folder"
    end
  end
  context "methods" do
    let(:ingest_folder) { FactoryGirl.build(:ingest_folder, :user => user) }
    context "#checksum_file_location" do
      context "checksum file not specified" do
        let(:expected_location) { File.join(IngestFolder.default_checksum_file_location, "#{ingest_folder.sub_path}.txt") }
        it "should return the default path with subpath-based filename" do
          expect(ingest_folder.checksum_file_location).to eql(expected_location)
        end
      end
      context "relative checksum file specified" do
        let(:file_name) { "checksum_file.txt" }
        let(:expected_location) { File.join(IngestFolder.default_checksum_file_location, file_name) }
        before {ingest_folder.checksum_file = file_name }
        it "should return the default path with specified filename" do
          expect(ingest_folder.checksum_file_location).to eql(expected_location)
        end
      end
      context "absolute checksum file specified" do
        let(:file_path) { "/dir/fixity/checksum_file.txt" }
        let(:expected_location) { file_path }
        before {ingest_folder.checksum_file = file_path }
        it "should return the default path with specified filename" do
          expect(ingest_folder.checksum_file_location).to eql(expected_location)
        end
      end
    end
  end
  context "operations" do
    let(:ingest_folder) { FactoryGirl.build(:ingest_folder, :user => user) }
    before do
      Dir.stub(:foreach).with("/mount/base/path/subpath").and_return(
        Enumerator.new { |y| y << "Thumbs.db" << "file01001.tif" << "file01002.tif" << "pdf" << "targets" }
      )
      Dir.stub(:foreach).with("/mount/base/path/subpath/pdf").and_return(
        Enumerator.new { |y| y << "file01.pdf" }
      )
      Dir.stub(:foreach).with("/mount/base/path/subpath/targets").and_return(
        Enumerator.new { |y| y << "Thumbs.db" << "T001.tiff" << "T002.tiff"}
      )
      File.stub(:directory?).and_return(false)
      File.stub(:directory?).with("/mount/base/path/subpath/pdf").and_return(true)
      File.stub(:directory?).with("/mount/base/path/subpath/targets").and_return(true)
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
      let(:parent_model) { DulHydra::Utils.reflection_object_class(DulHydra::Utils.relationship_object_reflection(IngestFolder.default_file_model, "parent")).name }
      before do
        IngestFolder.any_instance.stub(:checksum_file_location).and_return(File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'checksums.txt')) 
        ingest_folder.procezz
        user.batches.first.batch_objects.each do |obj|
          objects[obj.identifier] = obj
          obj.batch_object_datastreams.each { |ds| dss[obj.identifier] = { ds.name => ds } }
          obj.batch_object_relationships.each { |rel| rels[obj.identifier] = { rel.name => rel } }
        end
      end
      after { user.batches.first.destroy }
      it "should create the correct batch objects" do
        expect(user.batches.count).to eql(1)
        expect(user.batches.first.name).to eql(I18n.t('batch.ingest_folder.batch_name'))
        expect(user.batches.first.description).to eql(ingest_folder.abbreviated_path)
        expect(objects.fetch('f').model).to eql(parent_model)
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
