require 'spec_helper'

describe PermissionsController do
  let(:object) { FactoryGirl.create(:test_model) }
  let(:user) { FactoryGirl.create(:user) }
  before do 
    sign_in user 
  end
  after(:all) { user.delete }
  after(:each) do
    object.delete
    sign_out user
  end
  describe "#edit" do
    it "should render the edit template" do
      controller.current_ability.can(:edit, String) do |obj|
        obj == object.pid
      end
      get :edit, id: object
      response.should render_template(:edit)      
    end
  end
  describe "#update" do
    before do
      controller.current_ability.can(:update, String) do |obj|
        obj == object.pid
      end
    end
    it "should update the permissions" do
      put :update, id: object, permissions: {discover_groups: ["public"], read_groups: ["registered"], edit_groups: ["editors", "managers"], discover_users: ["Sally", "Mitch"], read_users: ["Gil", "Ben"], edit_users: ["Rocky", "Gwen", "Teresa"]}
      object.reload
      object.discover_groups.should == ["public"]
      object.read_groups.should == ["registered"]
      object.edit_groups.should == ["editors", "managers"]
      object.discover_users.should == ["Sally", "Mitch"]
      object.read_users.should == ["Gil", "Ben"]
      object.edit_users.should == ["Rocky", "Gwen", "Teresa"]
    end
    it "should redirect to the show view" do
      put :update, id: object
      response.should redirect_to(permissions_path(object))
    end
  end
end
