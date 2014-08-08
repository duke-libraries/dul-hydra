require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

def create_collection
  post :create, admin_policy_id: FactoryGirl.create(:admin_policy).pid, descMetadata: {title: ["New Collection"]}
end

def new_collection
  get :new, admin_policy_id: FactoryGirl.create(:admin_policy).pid
end

describe CollectionsController, collections: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:create_object) { Proc.new { create_collection } }
    let(:new_object) { Proc.new { new_collection } }
  end

  describe "#create" do
    # has shared examples
    before { controller.current_ability.can(:create, Collection) }
    it "should set the admin policy" do
      create_collection
      expect(assigns(:current_object).admin_policy).to be_present
    end
  end

  describe "#items" do
    let(:collection) { FactoryGirl.create(:collection_has_item) }
    context "when the user can read the collection" do
      before do
        apo = collection.admin_policy
        apo.default_permissions = [{type: "user", access: "read", name: user.user_key}]
        apo.save
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
        apo = collection.admin_policy
        apo.default_permissions = [{type: "user", access: "read", name: user.user_key}]
        apo.save
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
    let(:collection) { FactoryGirl.create(:collection_has_target) }
    context "when the user can read the collection" do
      before do
        apo = collection.admin_policy
        apo.default_permissions = [{type: "user", access: "read", name: user.user_key}]
        apo.save
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
        item.children = FactoryGirl.create_list(:component_with_content, 2)
        item.parent = collection
        item.save
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
end
