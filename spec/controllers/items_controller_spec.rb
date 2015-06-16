require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

def create_item
  post :create, parent_id: collection.pid, descMetadata: {title: ["New Item"]}
end

def create_item_and_component opts={}
  checksum, checksum_type = opts.values_at(:checksum, :checksum_type)
  post :create, parent_id: collection.pid, descMetadata: {title: ["New Item"]}, content: {file: fixture_file_upload('imageA.tif', 'image/tiff'), checksum: checksum, checksum_type: checksum_type}
end

describe ItemsController, type: :controller, items: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:collection) { FactoryGirl.create(:collection) }
    let(:create_object) do
      Proc.new do
        controller.current_ability.can(:add_children, collection)
        create_item
      end
    end
    let(:new_object) do
      Proc.new do
        controller.current_ability.can(:add_children, collection)
        get :new, parent_id: collection.pid
      end
    end
  end

  describe "#new" do
    # see shared examples
    let(:collection) { FactoryGirl.create(:collection) }
    before { controller.current_ability.can(:create, Item) }
    context "when the user cannot add children to the collection" do
      before { controller.current_ability.cannot(:add_children, collection) }
      it "should be unauthorized" do
        get :new, parent_id: collection.pid
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#create" do
    # see shared examples
    let(:collection) { FactoryGirl.create(:collection) }
    before { controller.current_ability.can(:create, Item) }
    context "when the current user cannot add children to the collection" do
      before { controller.current_ability.cannot(:add_children, collection) }
      it "should be unauthorized" do
        create_item
        expect(response.response_code).to eq(403)
      end
    end
    context "when the current user can add children to the collection" do
      before { controller.current_ability.can(:add_children, collection) }
      it "should set the admin policy id to the collection's admin policy id" do
        create_item
        expect(assigns(:current_object).admin_policy_id).to eq(collection.admin_policy_id)
      end
      context "adding a component file at creation time" do
        it "should create the component" do
          expect { create_item_and_component }.to change { Component.count }.by(1)
        end
        it "the component should have content" do
          create_item_and_component
          expect(assigns(:current_object).children.first).to have_content
        end
        it "should correctly set the MIME type" do
          create_item_and_component
          expect(assigns(:current_object).children.first.content_type).to eq("image/tiff")
        end
        it "should store the original file name" do
          create_item_and_component
          expect(assigns(:current_object).children.first.original_filename).to eq("imageA.tif")
        end
        it "should grant edit permission to the user" do
          create_item_and_component
          expect(assigns(:current_object).children.first.edit_users).to include(user.user_key)
        end
        it "should copy the admin policy id of the item to the component" do
          create_item_and_component
          expect(assigns(:current_object).children.first.admin_policy_id).to eq(assigns(:current_object).admin_policy_id)
        end
        it "should have a thumbnail (if it's an image)" do
          create_item_and_component
          expect(assigns(:current_object).children.first).to have_thumbnail
        end
        it "should create events" do
          expect{ create_item_and_component }.to change{ Ddr::Events::CreationEvent.count }.by(2)
        end
        it "should validate the checksum if provided" do
          expect_any_instance_of(Component).to receive(:validate_checksum!)
          create_item_and_component(checksum: "bda5fda452d0047c27e9e0048ed59428cb9e6d5d46fe9c27dff5c8e39b75a59e", checksum_type: "SHA-256")
        end
        context "checksum doesn't match" do
          let(:bad_checksum) { "5a2b997867b99ef10ed02aab1e406a798a71f5f630aeeca5ebdf443d4d62bcd1" }
          it "should not create a new object" do
          pending("Resolution of https://github.com/duke-libraries/ddr-models/issues/204")
          expect{ create_item_and_component(checksum: bad_checksum) }.not_to change{ Component.count }
          end
          it "should not create an event" do
            pending("Resolution of https://github.com/duke-libraries/ddr-models/issues/204")
            expect{ create_item_and_component(checksum: bad_checksum) }.to change{ Ddr::Events::CreationEvent.count }.by(1)
          end
        end
      end
    end
  end

  describe "#components" do
    let(:item) { FactoryGirl.create(:item) }
    context "when the user can read the item" do
      before { controller.current_ability.can(:read, item) }
      it "should render the components" do
        expect(get :components, id: item).to render_template(:components)
      end
    end
    context "when the user cannot read the item" do
      it "should be unauthorized" do
        get :components, id: item
        expect(response.response_code).to eq 403
      end
    end
  end

end
