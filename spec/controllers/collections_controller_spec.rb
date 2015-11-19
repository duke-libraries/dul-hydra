require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

describe CollectionsController, type: :controller, collections: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:object) { FactoryGirl.create(:collection) }
  end

  describe "#new" do
    describe "when the user can create a Collection" do
      before { controller.current_ability.can(:create, Collection) }
      it "renders the new template" do
        get :new
        expect(response).to render_template(:new)
      end
    end
    describe "when the user cannot create a Collection" do
      it "is unauthorized" do
        get :new
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#create" do
    describe "when the user can create a Collection" do
      before { controller.current_ability.can(:create, Collection) }
      it "persists the new Collection" do
        expect {
          post :create, descMetadata: {title: ["New Collection"]}
        }.to change{ Collection.count }.by(1)
      end
      it "doesn't save an empty string metadata value" do
        post :create, descMetadata: {title: ["New Collection"], description: [""]}
        expect(assigns(:current_object).dc_description).to be_blank
      end
      it "grants the Curator role to the creator" do
        post :create, descMetadata: {title: ["New Collection"]}
        expect(assigns(:current_object).roles.granted?(role_type: "Curator", agent: user.to_s, scope: "resource"))
          .to be true
      end
      it "records a creation event" do
        expect {
          post :create, descMetadata: {title: ["New Collection"]}
        }.to change { Ddr::Events::CreationEvent.count }.by(1)
      end
      it "redirects after creating the new object" do
        post :create, descMetadata: {title: ["New Collection"]}
        expect(response).to be_redirect
      end
    end
    describe "when the user cannot create objects of this type" do
      it "is unauthorized" do
        post :create, descMetadata: {title: ["New Collection"]}
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#items" do
    let(:collection) { FactoryGirl.create(:collection, :has_item) }
    describe "when the user can read the collection" do
      before do
        collection.roles.grant role_type: "Viewer", agent: user
        collection.save!
      end
      it "renders the items" do
        get :items, id: collection
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
    let(:collection) { FactoryGirl.create(:collection, :has_attachment) }
    context "when the user can read the collection" do
      before do
        collection.roles.grant role_type: "Viewer", agent: user
        collection.save!
      end
      it "should render the attachments" do
        get :attachments, id: collection
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
    describe "when the user can read the collection" do
      before do
        collection.roles.grant role_type: "Viewer", agent: user
        collection.save!
      end
      it "renders the targets" do
        get :targets, id: collection
        expect(response).to render_template(:targets)
      end
    end
    describe "when the user cannot read the collection" do
      it "is unauthorized" do
        get :targets, id: collection
        expect(response.response_code).to eq 403
      end
    end
  end

end
