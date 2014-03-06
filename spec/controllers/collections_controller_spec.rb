require 'spec_helper'

describe CollectionsController do
  let(:user) { FactoryGirl.create(:user) }
  before do
    DulHydra.stub(:creatable_models).and_return(["Collection"])
    DulHydra.stub(:ability_group_map).and_return({"Collection" => {create: "collection_admins"}}.with_indifferent_access)
    User.any_instance.stub(:groups).and_return(["collection_admins"])
    sign_in user
  end
  after { user.destroy }
  it "should have a 'new' action" do
    expect(get :new).to render_template(:new)
  end
  describe "#create" do
    let(:admin_policy) { FactoryGirl.create(:admin_policy) }
    before { post :create, collection: {title: "New Collection"}, admin_policy_id: admin_policy.pid }
    after { ActiveFedora::Base.destroy_all }
    it "should create a new object" do
      expect(assigns(:collection).title).to eq(["New Collection"])
    end
    it "should grant edit permission to the user" do
      expect(assigns(:collection).edit_users).to include(user.user_key)
    end
    it "should create an event log" do
      expect(assigns(:collection).event_logs(action: "create").count).to eq(1)
    end
  end

end
