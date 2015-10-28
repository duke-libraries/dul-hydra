require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

def create_component opts={}
  checksum, checksum_type = opts.values_at(:checksum, :checksum_type)
  post :create, parent_id: item.id, content: {file: fixture_file_upload('imageA.tif', 'image/tiff'), checksum: checksum, checksum_type: checksum_type}
end

describe ComponentsController, type: :controller, components: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:item) { FactoryGirl.create(:item) }
    let(:create_object) do
      Proc.new do
        controller.current_ability.can(:add_children, item)
        create_component
      end
    end
    let(:new_object) do
      Proc.new do
        controller.current_ability.can(:add_children, item)
        get :new, parent_id: item.id
      end
    end
  end

  describe "#new" do
    # see shared examples
    let(:item) { FactoryGirl.create(:item) }
    context "and user cannot add children to item" do
      # before { item.save! }
      it "should be unauthorized" do
        get :new, parent_id: item.id
        expect(response.response_code).to eq(403)
      end
    end
    context "and user can add children to item" do
      before { controller.current_ability.can(:add_children, item) }
      it "should be authorized" do
        get :new, parent_id: item.id
        expect(response.response_code).to eq(200)
      end
    end
  end

  describe "#create" do
    let(:item) { FactoryGirl.create(:item) }
    context "when the user can add children to the item" do
      before { controller.current_ability.can(:add_children, item) }
      it "should create a new object" do
        expect{ create_component }.to change{ Component.count }.by(1)
      end
      it "should have content" do
        create_component
        expect(assigns(:current_object)).to have_content
      end
      it "should correctly set the MIME type" do
        create_component
        expect(assigns(:current_object).content_type).to eq("image/tiff")
      end
      it "should store the original file name" do
        create_component
        expect(assigns(:current_object).original_filename).to eq("imageA.tif")
      end
      it "should grant the Editor role in resource scope to the user" do
        create_component
        expect(assigns(:current_object).roles.granted?(type: "Editor", agent: user.agent, scope: "resource"))
          .to be true
      end
      it "should have a parent" do
        create_component
        expect(assigns(:current_object).parent).to eq(item)
      end
      it "should update derivatives" do
        expect_any_instance_of(Ddr::Managers::DerivativesManager).to receive(:update_derivatives)
        create_component
      end
      it "should create an event" do
        expect{ create_component }.to change{ Ddr::Events::CreationEvent.count }.by(1)
      end
      it "should redirect to the component edit page" do
        create_component
        expect(response).to redirect_to(action: "edit", id: assigns(:current_object))
      end
      it "should validate the checksum when provided" do
        expect(controller).to receive(:validate_checksum)
        create_component(checksum: "bda5fda452d0047c27e9e0048ed59428cb9e6d5d46fe9c27dff5c8e39b75a59e", checksum_type: "SHA-256")
      end
    end
    context "when the user cannot add children to the item" do
      before { controller.current_ability.cannot(:add_children, item) }
      it "should be unauthorized" do
        create_component
        expect(response.response_code).to eq(403)
      end
    end
  end
end
