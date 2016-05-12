require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

describe ComponentsController, type: :controller, components: true do

  let(:item) { FactoryGirl.create(:item) }
  let(:file) { fixture_file_upload('imageA.tif', 'image/tiff') }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:object) { FactoryGirl.create(:component) }
  end

  describe "#new" do
    describe "when the user can add children to the parent Item" do
      before do
        item.roles.grant role_type: "Contributor", agent: user
        item.save!
      end
      it "renders the new template" do
        get :new, parent_id: item
        expect(response).to render_template(:new)
      end
    end
    describe "when the user cannot create an object of this type" do
      it "is unauthorized" do
        get :new, parent_id: item
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#create" do
    describe "when the user can add children to the item" do
      before do
        item.roles.grant role_type: "Contributor", agent: user
        item.save!
      end
      it "persists a new object" do
        expect {
          post :create, parent_id: item, content: {file: file}
        }.to change{ Component.count }.by(1)
      end
      it "persists the content" do
        post :create, parent_id: item, content: {file: file}
        expect(assigns(:current_object)).to have_content
      end
      it "correctly sets the MIME type" do
        post :create, parent_id: item, content: {file: file}
        expect(assigns(:current_object).content_type).to eq("image/tiff")
      end
      it "stores the original file name" do
        post :create, parent_id: item, content: {file: file}
        expect(assigns(:current_object).original_filename).to eq("imageA.tif")
      end
      it "grants the Editor role in resource scope to the user" do
        post :create, parent_id: item, content: {file: file}
        expect(assigns(:current_object).roles.granted?(role_type: "Editor", agent: user.agent, scope: "resource"))
          .to be true
      end
      it "has the item as parent" do
        post :create, parent_id: item, content: {file: file}
        expect(assigns(:current_object).parent).to eq(item)
      end
      it "updates derivatives" do
        expect_any_instance_of(Ddr::Managers::DerivativesManager).to receive(:update_derivatives)
        post :create, parent_id: item, content: {file: file}
      end
      it "records a creation event" do
        expect {
          post :create, parent_id: item, content: {file: file}
        }.to change{ Ddr::Events::CreationEvent.count }.by(1)
      end
      it "redirects to the component edit page" do
        post :create, parent_id: item, content: {file: file}
        expect(response).to redirect_to(action: "edit", id: assigns(:current_object))
      end
      it "validates the checksum when provided" do
        expect(controller).to receive(:validate_checksum)
        post :create, parent_id: item, content: {file: file, checksum: "75e2e0cec6e807f6ae63610d46448f777591dd6b", checksum_type: "SHA-1"}
      end
    end
    describe "when the user cannot add children to the item" do
      it "is unauthorized" do
        post :create, parent_id: item, content: {file: file}
        expect(response.response_code).to eq(403)
      end
    end
  end
end
