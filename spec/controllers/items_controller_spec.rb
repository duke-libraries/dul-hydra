require 'spec_helper'

describe ItemsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:collection) { FactoryGirl.create(:collection) }
  before do
    collection.edit_users = [user.user_key]
    collection.save!
    DulHydra.stub(:creatable_models).and_return(["Item"])
    DulHydra.stub(:ability_group_map).and_return({"Item" => {create: "item_creators"}}.with_indifferent_access)
    User.any_instance.stub(:groups).and_return(["item_creators"])
    sign_in user
  end
  after do
    ActiveFedora::Base.destroy_all
    User.destroy_all
  end
  it "should have a 'new' action" do
    expect(get :new, id: collection).to render_template(:new)
  end
  describe "#create" do
    before { post :create, item: {title: "New Item"}, id: collection }
    it "should create a new object" do
      expect(assigns(:item).title).to eq(["New Item"])
    end
    it "should grant edit permission to the user" do
      expect(assigns(:item).edit_users).to include(user.user_key)
    end
    it "should create an event log" do
      expect(assigns(:item).event_logs(action: "create").count).to eq(1)
    end
    it "should redirect to the item show page" do
      expect(response).to redirect_to(object_path(assigns(:item)))
    end
  end

end
