require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

describe ItemsController, type: :controller, items: true do

  let(:collection) { FactoryGirl.create(:collection) }
  let(:file) { fixture_file_upload('imageA.tif', 'image/tiff') }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:object) { FactoryGirl.create(:item) }
  end

  describe "#new" do
    describe "when the user can create an Item" do
      before { controller.current_ability.can(:create, Item) }
      it "renders the new template" do
        get :new, parent_id: collection
        expect(response).to render_template(:new)
      end
    end
    describe "when the user cannot add children to the collection" do
      it "is unauthorized" do
        get :new, parent_id: collection
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#create" do
    describe "when the user cannot add children to the collection" do
      it "is unauthorized" do
        post :create, parent_id: collection, descMetadata: {title: ["New Item"]}
        expect(response.response_code).to eq(403)
      end
    end
    describe "when the user can add children to the collection" do
      before do
        collection.roles.grant role_type: "Contributor", agent: user
        collection.save!
      end
      it "persists the new Item" do
        expect {
          post :create, parent_id: collection, descMetadata: {title: ["New Item"]}
        }.to change{ Item.count }.by(1)
      end
      it "doesn't save an empty string metadata value" do
        post :create, parent_id: collection, descMetadata: {title: ["New Item"], description: [""]}
        expect(assigns(:current_object).dc_description).to be_blank
      end
      it "grants the Editor role to the creator" do
        post :create, parent_id: collection, descMetadata: {title: ["New Item"]}
        expect(assigns(:current_object).roles.granted?(role_type: "Editor", agent: user.to_s, scope: "resource"))
          .to be true
      end
      it "records a creation event" do
        expect {
          post :create, parent_id: collection, descMetadata: {title: ["New Item"]}
        }.to change { Ddr::Events::CreationEvent.count }.by(1)
      end
      it "redirects after creating the new object" do
        post :create, parent_id: collection, descMetadata: {title: ["New Item"]}
        expect(response).to be_redirect
      end
      it "sets the admin policy id to the collection's admin policy id" do
        post :create, parent_id: collection, descMetadata: {title: ["New Item"]}
        expect(assigns(:current_object).admin_policy_id).to eq(collection.admin_policy_id)
      end
      describe "adding a Component at creation time" do
        it "creates the component" do
          expect {
            post :create, parent_id: collection, descMetadata: {title: ["New Item"]}, content: {file: file}
          }.to change { Component.count }.by(1)
        end
        it "adds content to the Component" do
          post :create, parent_id: collection, descMetadata: {title: ["New Item"]}, content: {file: file}
          expect(assigns(:current_object).children.first).to have_content
        end
        it "correctly sets the MIME type" do
          post :create, parent_id: collection, descMetadata: {title: ["New Item"]}, content: {file: file}
          expect(assigns(:current_object).children.first.content_type).to eq("image/tiff")
        end
        it "stores the original file name" do
          post :create, parent_id: collection, descMetadata: {title: ["New Item"]}, content: {file: file}
          expect(assigns(:current_object).children.first.original_filename).to eq("imageA.tif")
        end
        it "copies the admin policy id of the item to the component" do
          post :create, parent_id: collection, descMetadata: {title: ["New Item"]}, content: {file: file}
          expect(assigns(:current_object).children.first.admin_policy_id)
            .to eq(assigns(:current_object).admin_policy_id)
        end
        it "has a thumbnail (if it's an image)" do
          post :create, parent_id: collection, descMetadata: {title: ["New Item"]}, content: {file: file}
          expect(assigns(:current_object).children.first).to have_thumbnail
        end
        it "records creation events" do
          expect {
            post :create, parent_id: collection, descMetadata: {title: ["New Item"]}, content: {file: file}
          }.to change{ Ddr::Events::CreationEvent.count }.by(2)
        end
        it "validates the checksum if provided" do
          expect_any_instance_of(Component).to receive(:validate_checksum!)
          post :create, parent_id: collection, descMetadata: {title: ["New Item"]}, content: {file: file, checksum: "75e2e0cec6e807f6ae63610d46448f777591dd6b", checksum_type: "SHA-1"}
        end
      end
    end
  end

  describe "#components" do
    let(:item) { FactoryGirl.create(:item) }
    describe "when the user cannot read the item" do
      it "is unauthorized" do
        get :components, id: item
        expect(response.response_code).to eq 403
      end
    end
  end

end
