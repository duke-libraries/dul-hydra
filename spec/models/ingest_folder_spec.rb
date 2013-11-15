require 'spec_helper'

describe IngestFolder do

  let(:user) { FactoryGirl.create(:user) }
  before do
    File.stub(:readable?).and_return(true)
    File.stub(:readable?).with("/base/path/unreadable/").and_return(false)
    File.stub(:readable?).with("/base/path/subpath/unreadable.txt").and_return(false)
    IngestFolder.stub(:permitted_folders).with(user).and_return(["/base/path/"])
  end
  after do
    user.destroy
  end
  context "validation" do
    it "should have a valid factory" do
      FactoryGirl.build(:ingest_folder, :user => user).should be_valid
    end
    it "should require a permitted base path" do
      ingest_folder = FactoryGirl.build(:ingest_folder, :user => user, :base_path => "/forbidden/path/")
      ingest_folder.should_not be_valid
      ingest_folder.errors.should have_key(:base_path)
    end
    it "should require a subpath" do
      ingest_folder = FactoryGirl.build(:ingest_folder, :user => user, :sub_path => "")
      ingest_folder.should_not be_valid
      ingest_folder.errors.should have_key(:sub_path)
    end
    it "should require a readable subpath" do
      ingest_folder = FactoryGirl.build(:ingest_folder, :user => user, :sub_path => "unreadable/")
      ingest_folder.should_not be_valid
      ingest_folder.errors.should have_key(:sub_path)
    end
    it "should require a collection pid" do
      ingest_folder = FactoryGirl.build(:ingest_folder, :user => user, :collection_pid => "")
      ingest_folder.should_not be_valid
      ingest_folder.errors.should have_key(:collection_pid)
    end
    it "should require an admin policy pid" do
      ingest_folder = FactoryGirl.build(:ingest_folder, :user => user, :admin_policy_pid => "")
      ingest_folder.should_not be_valid
      ingest_folder.errors.should have_key(:admin_policy_pid)
    end
    it "should require a readable checksum file if provided" do
      ingest_folder = FactoryGirl.build(:ingest_folder, :user => user, :checksum_file => "/subpath/unreadable.txt")
      ingest_folder.should_not be_valid
      ingest_folder.errors.should have_key(:checksum_file)
    end
  end

end
