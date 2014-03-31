require 'spec_helper'

describe AdminPoliciesController do
  let(:user) { FactoryGirl.create(:user) }
  before do
    DulHydra.stub(:creatable_models).and_return(["AdminPolicy"])
    DulHydra.stub(:ability_group_map).and_return({"AdminPolicy" => {create: "admin_policy_creators"}}.with_indifferent_access)
    User.any_instance.stub(:groups).and_return(["admin_policy_creators"])
    sign_in user
  end
  after { user.destroy }
  it "should have a 'new' action" do
    expect(get :new).to render_template(:new)
  end
  describe "#create" do
    before { post :create, admin_policy: {title: "New Policy"} }
    after { ActiveFedora::Base.destroy_all }
    it "should create a new object" do
      expect(assigns(:admin_policy)).to be_persisted
    end
    it "should grant edit permission to the user" do
      expect(assigns(:admin_policy).edit_users).to include(user.user_key)
    end
    it "should create an event log" do
      expect(assigns(:admin_policy).event_logs(action: "create").count).to eq(1)
    end
  end

end
