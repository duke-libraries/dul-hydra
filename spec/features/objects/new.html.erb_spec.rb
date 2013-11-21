require 'spec_helper'

describe "objects/new.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  before do
    DulHydra.creatable_models = ["AdminPolicy", "Collection"]
    DulHydra.groups = {admin_policy_creators: "admins", collection_creators: "collection_admins"}.with_indifferent_access
    login_as user
  end
  after { user.delete }
  context "user cannot create models" do
    it "should return unauthorized" do
      visit new_object_path("collection")
      page.status_code.should == 403
    end
  end
  context "user is not authorized to create requested model" do
    before { user.stub(:groups).and_return(["admins", "public", "registered"]) }
    it "should return unauthorized" do
      visit new_object_path("collection")
      page.status_code.should == 403
    end
  end
  context "user is authorized to create requested model" do
    before { user.stub(:groups).and_return(["collection_admins", "public", "registered"]) }
    it "should render the new template" do
      visit new_object_path("collection")
      page.status_code.should == 200
    end
  end
end
