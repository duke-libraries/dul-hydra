require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

def create_collection
  post :create, descMetadata: {title: ["New Collection"]}
end

def new_collection
  get :new
end

def update_policy
  patch :default_permissions, id: object, permissions: {"discover" => ["group:public", "user:Sally", "user:Mitch"], "read" => ["group:registered", "user:Gil", "user:Ben"], "edit" => ["group:editors", "group:managers", "user:Rocky", "user:Gwen", "user:Teresa"]}, license: {"title" => "No Access", "description" => "No one can get to it", "url" => "http://www.example.com"}
end

describe CollectionsController, type: :controller, collections: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:create_object) { Proc.new { create_collection } }
    let(:new_object) { Proc.new { new_collection } }
  end

  describe "#items" do
    let(:collection) { FactoryGirl.create(:collection, :has_item) }
    context "when the user can read the collection" do
      before do
        collection.permissions_attributes = [{type: "user", access: "read", name: user.user_key}]
        collection.save
      end
      it "should render the items" do
        get :items, id: collection
        expect(response).to be_successful
        expect(response).to render_template(:items)
      end
    end
    context "when the user cannot read the collection" do
      it "should be unauthorized" do
        get :items, id: collection
        expect(response.response_code).to eq 403
      end
    end
  end

  describe "#attachments" do
    let(:collection) { FactoryGirl.create(:collection) }
    let(:attachment) { FactoryGirl.create(:attachment) }
    before do
      attachment.attached_to = collection
      attachment.save
    end
    context "when the user can read the collection" do
      before do
        collection.permissions_attributes = [{type: "user", access: "read", name: user.user_key}]
        collection.save
      end
      it "should render the attachments" do
        get :attachments, id: collection
        expect(response).to be_successful
        expect(response).to render_template(:attachments)
      end
    end
    context "when the user cannot read the collection" do
      it "should be unauthorized" do
        get :attachments, id: collection
        expect(response.response_code).to eq 403
      end
    end
  end

  describe "#targets" do
    let(:collection) { FactoryGirl.create(:collection, :has_target) }
    context "when the user can read the collection" do
      before do
        collection.permissions_attributes = [{type: "user", access: "read", name: user.user_key}]
        collection.save
      end
      it "should render the targets" do
        get :targets, id: collection
        expect(response).to be_successful
        expect(response).to render_template(:targets)
      end
    end
    context "when the user cannot read the collection" do
      it "should be unauthorized" do
        get :targets, id: collection
        expect(response.response_code).to eq 403
      end
    end
  end

  describe "#collection_info" do
    let(:collection) { FactoryGirl.create(:collection) }
    let(:items) { FactoryGirl.create_list(:item, 3) }
    before do
      items.each do |item|
        item.parent = collection
        item.save
        item.children = FactoryGirl.create_list(:component, 2)
      end
    end
    context "when the user can read the collection" do
      before { controller.current_ability.can(:read, collection) }
      it "should report the statistics" do
        get :collection_info, id: collection
        expect(response).to render_template(:collection_info)
        expect(controller.send(:collection_report)[:components]).to eq(6)
        expect(controller.send(:collection_report)[:items]).to eq(3)
        expect(controller.send(:collection_report)[:total_file_size]).to eq(60192)
      end
    end
    context "when the user cannot read the collection" do
      before { controller.current_ability.cannot(:read, collection) }
      it "should be unauthorized" do
        get :collection_info, id: collection
        expect(response.response_code).to eq(403)
      end
    end
  end
  
  describe "#default_permissions" do
    let(:object) { FactoryGirl.create(:collection) }
    context "GET" do
      context "when the user can edit the object" do
        before do
          object.edit_users = [user.user_key]
          object.save
        end
        it "should render the default_permissions template" do
          expect(get :default_permissions, id: object).to render_template("default_permissions")      
        end
      end
      context "when the user cannot edit the object" do
        it "should be unauthorized" do
          get :default_permissions, id: object
          expect(response.response_code).to eq(403)
        end
      end
    end
    context "PATCH" do
      context "when the user can edit the object" do
        before do
          object.edit_users = [user.user_key]
          object.save
        end
        it "should update the default permissions" do
          update_policy
          object.reload
          expect(object.default_discover_groups).to eq(["public"])
          expect(object.default_read_groups).to eq(["registered"])
          expect(object.default_edit_groups).to eq(["editors", "managers"])
          expect(object.default_discover_users).to eq(["Sally", "Mitch"])
          expect(object.default_read_users).to eq(["Gil", "Ben"])
          expect(object.default_edit_users).to eq(["Rocky", "Gwen", "Teresa"])
          expect(object.default_license_title).to eq("No Access")
          expect(object.default_license_description).to eq("No one can get to it")
          expect(object.default_license_url).to eq("http://www.example.com")
        end
        it "should redirect to the show view" do
          update_policy
          expect(response).to redirect_to(action: "show", tab: "default_permissions")
        end
        it "should create an event log entry for the action" do
          expect{ update_policy }.to change{ object.update_events.count }.by(1)
        end
      end
      context "when the user cannot edit the object" do
        it "should be unauthorized" do
          update_policy
          expect(response.response_code).to eq(403)
        end
      end
    end
  end

end
