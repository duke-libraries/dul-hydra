require 'spec_helper'

describe PermissionsController do
  let(:user) { FactoryGirl.create(:user) }
  before do 
    object.edit_users = [user.user_key]
    object.save
    sign_in user 
  end
  after(:each) do
    object.delete
    sign_out user
    user.delete
  end
  describe "#edit" do
    context "permissions" do
      let(:object) { FactoryGirl.create(:test_model) }
      it "should render the edit template" do
        get :edit, id: object
        response.should render_template("edit")      
      end
    end
    context "default permissions" do
      let(:object) { AdminPolicy.create(title: "Test Policy") }
      it "should render the edit_default_permissions template" do
        get :edit, id: object, default_permissions: true
        response.should render_template("edit_default_permissions")      
      end
    end
  end
  describe "#update" do
    context "permissions" do
      let(:object) { FactoryGirl.create(:test_model) }
      it "should update the permissions" do
        put :update, id: object, permissions: {"discover" => ["group:public", "user:Sally", "user:Mitch"], "read" => ["group:registered", "user:Gil", "user:Ben"], "edit" => ["group:editors", "group:managers", "user:Rocky", "user:Gwen", "user:Teresa"]}, license: {"title" => "No Access", "description" => "No one can get to it", "url" => "http://www.example.com"}
        object.reload
        object.discover_groups.should == ["public"]
        object.read_groups.should == ["registered"]
        object.edit_groups.should == ["editors", "managers"]
        object.discover_users.should == ["Sally", "Mitch"]
        object.read_users.should == ["Gil", "Ben"]
        object.edit_users.should == ["Rocky", "Gwen", "Teresa"]
        object.license_title.should == "No Access"
        object.license_description.should == "No one can get to it"
        object.license_url.should == "http://www.example.com"
      end
      it "should redirect to the show view" do
        put :update, id: object, permissions: {"discover" => ["group:public", "user:Sally", "user:Mitch"], "read" => ["group:registered", "user:Gil", "user:Ben"], "edit" => ["group:editors", "group:managers", "user:Rocky", "user:Gwen", "user:Teresa"]}, license: {"title" => "No Access", "description" => "No one can get to it", "url" => "http://www.example.com"}
        response.should redirect_to(permissions_path(object))
      end
    end
    context "default permissions" do
      let(:object) { AdminPolicy.create(title: "Test Policy") }
      it "should update the default permissions" do
        put :update, id: object, permissions: {"discover" => ["group:public", "user:Sally", "user:Mitch"], "read" => ["group:registered", "user:Gil", "user:Ben"], "edit" => ["group:editors", "group:managers", "user:Rocky", "user:Gwen", "user:Teresa"]}, license: {"title" => "No Access", "description" => "No one can get to it", "url" => "http://www.example.com"}, default_permissions: true
        object.reload
        object.default_discover_groups.should == ["public"]
        object.default_read_groups.should == ["registered"]
        object.default_edit_groups.should == ["editors", "managers"]
        object.default_discover_users.should == ["Sally", "Mitch"]
        object.default_read_users.should == ["Gil", "Ben"]
        object.default_edit_users.should == ["Rocky", "Gwen", "Teresa"]
        object.default_license_title.should == "No Access"
        object.default_license_description.should == "No one can get to it"
        object.default_license_url.should == "http://www.example.com"
      end
      it "should redirect to the show view" do
        put :update, id: object, permissions: {"discover" => ["group:public", "user:Sally", "user:Mitch"], "read" => ["group:registered", "user:Gil", "user:Ben"], "edit" => ["group:editors", "group:managers", "user:Rocky", "user:Gwen", "user:Teresa"]}, license: {"title" => "No Access", "description" => "No one can get to it", "url" => "http://www.example.com"}, default_permissions: true
        response.should redirect_to(default_permissions_path(object))
      end
    end
  end
end
