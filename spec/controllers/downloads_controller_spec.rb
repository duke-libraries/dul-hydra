require 'spec_helper'

describe DownloadsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  before do
    obj.read_users = [user.user_key]
    obj.save
    sign_in user
  end
  context "object (i.e. content) download" do
    let(:obj) { FactoryGirl.create(:test_content) }
    before { get :show, id: obj }
    it "should download successfully" do
      expect(response).to be_successful
    end
    it "should attach the file using the original filename" do
      expect(response.headers["Content-Disposition"]).to match(/filename="#{obj.original_filename}"/)
    end
  end
  context "descMetadata download" do
    let(:obj) { FactoryGirl.create(:collection) }
    let(:download_name) { "#{obj.descMetadata.default_file_prefix}.txt" }
    it "should download successfully" do
      get :show, id: obj, datastream_id: "descMetadata"
      expect(response).to be_successful
    end
    it "should have a .txt filename extension" do
      get :show, id: obj, datastream_id: "descMetadata"
      expect(response.header["Content-Disposition"]).to match(/filename="#{download_name}"/)
    end
  end
  context "rightsMetadata download" do
    let(:obj) { FactoryGirl.create(:test_model) }
    it "should download successfully" do
      get :show, id: obj, datastream_id: "rightsMetadata"
      expect(response).to be_successful
    end
  end
end
