require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

def create_component checksum = "bda5fda452d0047c27e9e0048ed59428cb9e6d5d46fe9c27dff5c8e39b75a59e"
  post :create, parent: item, component: {title: "New Component", description: ""}, content: fixture_file_upload('image1.tiff', 'image/tiff'), checksum: checksum
end

describe ComponentsController, components: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:item) { FactoryGirl.create(:item) }
    let(:create_object) do
      Proc.new do
        item.edit_users = [user.user_key]
        item.save
        create_component
      end
    end
    let(:new_object) do
      Proc.new do
        controller.current_ability.can(:add_children, item)
        get :new, parent: item
      end
    end
  end

  describe "#new" do
    # see shared examples
    let(:item) { FactoryGirl.create(:item) }
    context "when user can create components" do
      before { controller.current_ability.can(:create, Component) }
      context "and user cannot add children to item" do
        before { controller.current_ability.cannot(:add_children, item) }
        it "should be unauthorized" do
          get :new, parent: item
          expect(response.response_code).to eq(403)
        end
      end
    end
  end

  describe "#create" do
    let(:item) { FactoryGirl.create(:item) }
    context "when the user can create components" do
      before { controller.current_ability.can(:create, Component) }      
      context "and the user can add children to the item" do
        before { controller.current_ability.can(:add_children, item) }
        it "should create a new object" do
          expect{ create_component }.to change{ Component.count }.by(1)
        end
        it "should have content" do
          create_component
          expect(assigns(:component)).to have_content
        end
        it "should correctly set the MIME type" do
          create_component
          expect(assigns(:component).content_type).to eq("image/tiff")
        end
        it "should store the original file name" do
          create_component
          expect(assigns(:component).original_filename).to eq("image1.tiff")
        end
        it "should grant edit permission to the user" do
          create_component
          expect(assigns(:component).edit_users).to include(user.user_key)
        end
        it "should have a parent" do
          create_component
          expect(assigns(:component).parent).to eq(item)
        end
        it "should have a thumbnail (if it's an image)" do
          create_component
          expect(assigns(:component)).to have_thumbnail
        end
        it "should create an event" do
          expect{ create_component }.to change{ CreationEvent.count }.by(1)
        end
        it "should redirect to the component show page" do
          create_component
          expect(response).to redirect_to(action: "show", id: assigns(:component))
        end
        context "when the parent is governed by an admin policy" do
          it "should copy the admin policy to the object"
        end
        context "when the parent is not governed by an admin policy" do
          it "should copy the parent's permissions"
        end
        context "checksum doesn't match" do
          let(:bad_checksum) { "5a2b997867b99ef10ed02aab1e406a798a71f5f630aeeca5ebdf443d4d62bcd1" }
          it "should not create a new object" do
            expect{ create_component checksum = bad_checksum }.not_to change{ Component.count }
          end
          it "should not create an event" do
            expect{ create_component checksum = bad_checksum }.not_to change{ CreationEvent.count }
          end
        end
      end
      context "and the user cannot add children to the item" do
        before { controller.current_ability.cannot(:add_children, item) }
        it "should be unauthorized" do
          create_component
          expect(response.response_code).to eq(403)
        end
      end
    end
    context "when the user cannot create components" do
      before { controller.current_ability.cannot(:create, Component) } 
      context "and the user can add children to the item" do
        before { controller.current_ability.can(:add_children, item) }
        it "should be unauthorized" do
          create_component
          expect(response.response_code).to eq(403)
        end
      end
      context "and the user cannot add children to the item" do
        before { controller.current_ability.cannot(:add_children, item) }
        it "should be unauthorized" do
          create_component
          expect(response.response_code).to eq(403)
        end
      end
    end
  end #create
end
