require 'spec_helper'

describe DownloadsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:obj) { FactoryGirl.create(:test_content) }
  after do
    user.delete
    obj.delete
  end
  before do
    obj.read_users = [user.user_key]
    obj.save
    sign_in user
  end
  it "should download successfully" do
    get :show, id: obj
    response.should be_successful
  end
end
