require 'spec_helper'

describe ObjectsController, objects: true do
  let(:object) { FactoryGirl.create(:test_content) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  after do
    User.destroy_all
    ActiveFedora::Base.destroy_all
  end
  describe "#show", descriptive_metadata: true do
    before do
      object.read_users = [user.user_key]
      object.save!
    end
    it "should render the show template" do
      expect(get :show, :id => object).to render_template(:show)
    end
  end
  describe "#edit", descriptive_metadata: true do
    before { controller.current_ability.can(:edit, object) }
    it "should render the hydra-editor edit template" do
      expect(get :edit, :id => object).to render_template('records/edit')
    end
  end
  describe "#update", descriptive_metadata: true do
    after { EventLog.destroy_all }
    context "when user can edit" do
      before do
        object.edit_users = [user.user_key]
        object.save!
        put :update, :id => object, :object => {:title => ["Updated"]}
      end
      it "should redirect to the descriptive metadata tab of the show page" do
        expect(response).to redirect_to(record_path(object))
      end
      it "should update the object" do
        expect(object.reload.title).to eq(["Updated"])
      end
      it "should create an event log entry for the update action" do
        expect(object.event_logs(action: "update").count).to eq(1)
      end
    end
    context "when user cannot edit" do
      before do
        controller.current_ability.cannot(:edit, object)
        put :update, :id => object, :object => {:title => ["Updated"]}
      end
      it "should be unauthorized" do
        expect(response.response_code).to eq(403)
      end
    end
  end
  describe "#upload" do
    context "via GET" do
      context "when user can upload" do
        before { controller.current_ability.can(:upload, object) }
        it "should render the upload template" do
          expect(get :upload, id: object).to render_template(:upload)
        end
      end
      context "when user cannot upload" do
        before { controller.current_ability.cannot(:upload, object) }
        it "should be unauthorized" do
          get :upload, id: object
          expect(response.response_code).to eq(403)
        end
      end
    end
    context "via PATCH" do
      context "when user can upload" do
        after { EventLog.destroy_all }
        before do
          object.edit_users = [user.user_key]
          object.save!
        end
        it "should upload the content" do
          patch :upload, id: object, content: fixture_file_upload('sample.pdf', 'application/pdf'), comment: "Corrected version"
          object.reload
          expect(object.source).to eq(['sample.pdf'])
          expect(object.content.size).to eq(83777)
          expect(object.content.mimeType).to eq("application/pdf")
        end
        it "should create an event log" do
          patch :upload, id: object, content: fixture_file_upload('sample.pdf'), comment: "Corrected version"
          expect(object.event_logs.count).to eq(1)
          expect(object.event_logs.first.comment).to eq("Corrected version")
        end
      end
      context "when user cannot upload" do
        it "should be unauthorized" do
          patch :upload, id: object, content: fixture_file_upload('sample.pdf'), comment: "Corrected version"
          expect(response.response_code).to eq(403)
        end
      end
    end
  end
end
