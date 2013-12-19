require 'spec_helper'

describe IngestFoldersController do

  let(:mount_point_name) { "base" }
  let(:mount_point_path) { "/mount/" }
  let(:checksum_directory) { "/fixity/fedora_ingest/" }
  let(:checksum_type) { "checksum-type" }
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
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
    File.stub(:readable?).and_return(true)
  end
  
  after { user.destroy }
  
  describe "#create" do
    
    let(:additional_attributes) { { :sub_path => '/subpath/subsubpath/' } }
    before do
      post :create, ingest_folder: FactoryGirl.attributes_for(:ingest_folder).merge(additional_attributes)
    end

    it "sets the ingest folder attributes correctly" do
      expect(assigns[:ingest_folder].add_parents).to be_true
      expect(assigns[:ingest_folder].model).to eql(IngestFolder.default_file_model)
      expect(assigns[:ingest_folder].base_path).to eql("base/path/")
      expect(assigns[:ingest_folder].sub_path).to eql('/subpath/subsubpath/')
      expect(assigns[:ingest_folder].checksum_file).to eql(File.join(IngestFolder.default_checksum_file_location, "subpath.txt"))
      expect(assigns[:ingest_folder].checksum_type).to eql(IngestFolder.default_checksum_type)
    end
    
  end
  
end