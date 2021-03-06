require 'support/collections_controller_spec_helper'
require 'support/shared_examples_for_repository_controllers'

def create_collection
  post :create, descMetadata: {title: ["New Collection"]}, admin_set: "foo"
end

def new_collection
  get :new
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
        collection.roles.grant type: "Viewer", agent: user
        collection.save!
      end
      it "renders the items" do
        get :items, id: collection
        expect(response).to be_successful
        expect(response).to render_template(:items)
      end
    end
    context "when the user cannot read the collection" do
      it "is unauthorized" do
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
      attachment.save!
    end
    context "when the user can read the collection" do
      before do
        collection.roles.grant type: "Viewer", agent: user
        collection.save!
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
        collection.roles.grant type: "Viewer", agent: user
        collection.save!
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

  describe "#publish" do
    let(:collection) { FactoryGirl.create(:collection, :has_item) }
    describe "when the user can publish the collection" do
      before do
        collection.roles.grant role_type: "Curator", agent: user
        collection.save!
      end
      it "publishes the collection and its descendants" do
        get :publish, id: collection
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(collection_url)
      end
    end
    describe "when the user cannot publish the collection" do
      it "is unauthorized" do
        get :publish, id: collection
        expect(response.response_code).to eq 403
      end
    end
  end

  describe "#unpublish" do
    let(:collection) { FactoryGirl.create(:collection, :has_item) }
    before { collection.publish! }
    describe "when the user can un-publish the collection" do
      before do
        collection.roles.grant role_type: "Curator", agent: user
        collection.save!
      end
      it "unpublishes the collection and its descendants" do
        get :unpublish, id: collection
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(collection_url)
      end
    end
    describe "when the user cannot unpublish the collection" do
      it "is unauthorized" do
        get :unpublish, id: collection
        expect(response.response_code).to eq 403
      end
    end
  end

  describe "#collection_info" do
    let(:collection) { FactoryGirl.create(:collection) }
    context "when the user can read the collection" do
      let(:items) { FactoryGirl.build_list(:item, 3) }
      before do
        allow_any_instance_of(Collection).to receive(:children).and_return(items)
        allow_any_instance_of(Collection).to receive(:components_from_solr).and_return(component_solr_doc_array.lazy)
        collection.roles.grant role_type: "Viewer", agent: user
        collection.save!
      end
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
