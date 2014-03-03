require 'spec_helper'

describe UploadsController, uploads: true do
  let(:object) { FactoryGirl.create(:test_content) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  after do
    User.destroy_all
    ActiveFedora::Base.destroy_all
  end
  context "via GET" do
    context "when user can upload" do
      before { controller.current_ability.can(:upload, object) }
      it "should render the show template" do
        expect(get :show, id: object).to render_template(:show)
      end
    end
    context "when user cannot upload" do
      before { controller.current_ability.cannot(:upload, object) }
      it "should be unauthorized" do
        get :show, id: object
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
        patch :update, id: object, content: fixture_file_upload('sample.pdf', 'application/pdf'), comment: "Corrected version"
        object.reload
        expect(object.source).to eq(['sample.pdf'])
        expect(object.content.size).to eq(83777)
        expect(object.content.mimeType).to eq("application/pdf")
      end
      it "should update the thumbnail" do
        patch :update, id: object, content: fixture_file_upload('sample.pdf', 'application/pdf'), comment: "Corrected version"
        object.reload
        expect(object.thumbnail.mimeType).to eq("image/png")
      end
      it "should create an event log" do
        patch :update, id: object, content: fixture_file_upload('sample.pdf'), comment: "Corrected version"
        expect(object.event_logs.count).to eq(1)
        expect(object.event_logs.first.comment).to eq("Corrected version")
      end
    end
    context "when user cannot upload" do
      it "should be unauthorized" do
        patch :update, id: object, content: fixture_file_upload('sample.pdf'), comment: "Corrected version"
        expect(response.response_code).to eq(403)
      end
    end
  end

end
