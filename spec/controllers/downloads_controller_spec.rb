require 'spec_helper'

describe DownloadsController do
  let(:user) { FactoryGirl.create(:user) }
  after do
    user.delete
    obj.delete
  end
  before do
    obj.read_users = [user.user_key]
    obj.save
    sign_in user
  end
  context "object (i.e. content) download" do
    let(:obj) { FactoryGirl.create(:test_content) }
    it "should download successfully" do
      get :show, id: obj
      response.should be_successful
    end
  end
  context "descMetadata download" do
    let(:obj) { FactoryGirl.create(:collection) }
    it "should download successfully" do
      get :show, id: obj, datastream_id: "descMetadata"
      response.should be_successful
    end
  end
  context "rightsMetadata download" do
    let(:obj) { FactoryGirl.create(:admin_policy) }
    it "should download successfully" do
      get :show, id: obj, datastream_id: "rightsMetadata"
      response.should be_successful
    end
  end
end
