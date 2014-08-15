require 'spec_helper'

describe ThumbnailController do
  let(:object) { FactoryGirl.create(:component_with_content) }
  let(:user) { FactoryGirl.create(:user) }
  before(:each) { sign_in user }
  context "user with discover permssion but not read permission on asset" do
    before do
      object.read_groups = ["registered"]
      object.discover_groups = ["public"]
      object.save
    end
    it "should allow user to download thumbnail" do
      get :show, :id => object
      response.should be_successful
    end
  end
  context "user with discover policy permission, but not read permission, on asset" do
    let(:collection) { Collection.create(title: "Test Policy") }
    before do
      collection.default_permissions = [{type: 'group', name: 'public', access: 'discover'},
                                        {type: 'group', name: 'registered', access: 'read'}]
      collection.save
      object.admin_policy = collection
      object.save
    end
    it "should allow user to download thumbnail" do
      get :show, :id => object
      response.should be_successful
    end
  end
end
