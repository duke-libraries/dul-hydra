require 'spec_helper'

def create_component
  post :create, id: item, component: {title: "New Component", description: "Part of an item"}, content: fixture_file_upload('sample.pdf', 'application/pdf'), checksum: "5a2b997867b99ef10ed02aab1e406a798a71f5f630aeeca5ebdf443d4d62bcd0"
end

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
    it "should create a new object" do
      create_component
      expect(assigns(:component)).to be_persisted
    end
    it "should grant edit permission to the user" do
      create_component
      expect(assigns(:component).edit_users).to include(user.user_key)
    end
    it "should create an event log" do
      create_component
      expect(assigns(:component).event_logs(action: "create").count).to eq(1)
    end
    it "should redirect to the component show page" do
      create_component
      expect(response).to redirect_to(object_path(assigns(:component)))
    end
    context "checksum doesn't match" do
      before { post :create, id: item, component: {title: "New Component", description: "Part of an item"}, content: fixture_file_upload('sample.pdf', 'application/pdf'), checksum: "5a2b997867b99ef10ed02aab1e406a798a71f5f630aeeca5ebdf443d4d62bcd1" }
      it "should not create a new object" do
        expect(assigns(:component)).to be_new
      end
      it "should not create an event log" do
        expect(assigns(:component).event_logs(action: "create").count).to eq(0)
      end
    end
  end
end
