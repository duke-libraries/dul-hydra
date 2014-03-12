require 'spec_helper'

describe ComponentsController, components: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:item) { FactoryGirl.create(:item) }
  before do
    item.edit_users = [user.user_key]
    item.save!
    DulHydra.stub(:creatable_models).and_return(["Component"])
    DulHydra.stub(:ability_group_map).and_return({"Component" => {create: "component_creators"}}.with_indifferent_access)
    User.any_instance.stub(:groups).and_return(["component_creators"])
    sign_in user
  end
  after do
    User.destroy_all
    ActiveFedora::Base.destroy_all
  end
  it "should have a 'new' action" do
    expect(get :new, id: item).to render_template(:new)
  end
  describe "#create" do
    before { post :create, id: item, component: {title: "New Component", description: "Part of an item"}, content: fixture_file_upload('sample.pdf', 'application/pdf') }
    it "should create a new object" do
      expect(assigns(:component).title).to eq(["New Component"])
    end
    it "should grant edit permission to the user" do
      expect(assigns(:component).edit_users).to include(user.user_key)
    end
    it "should create an event log" do
      expect(assigns(:component).event_logs(action: "create").count).to eq(1)
    end
  end
end
