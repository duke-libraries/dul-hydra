require 'spec_helper'

describe UploadsController, uploads: true do
  let(:object) { FactoryGirl.create(:component) }
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
        patch :update, id: object, content: fixture_file_upload('sample.pdf', 'application/pdf'), comment: "Corrected version", checksum: "5a2b997867b99ef10ed02aab1e406a798a71f5f630aeeca5ebdf443d4d62bcd0"
        object.reload
      end
      it "should upload the content" do
        expect(object).to have_content
      end
      it "should set the content type" do
        expect(object.content.mimeType).to eq("application/pdf")
      end
      it "should store the original file name in a property" do
        expect(object.original_filename).to eq("sample.pdf")
      end
      it "should create an event log" do
        expect(object.event_logs.count).to eq(1)
        expect(object.event_logs.first.comment).to eq("Corrected version")
      end
      it "should (re-)generate a thumbnail" do
        expect(object).to have_thumbnail
      end
    end
    context "when the checksum is invalid" do
      before do
        object.edit_users = [user.user_key]
        object.save!
        patch :update, id: object, content: fixture_file_upload('sample.pdf', 'application/pdf'), comment: "Corrected version", checksum: "5a2b997867b99ef10ed02aab1e406a798a71f5f630aeeca5ebdf443d4d62bcd1"
        object.reload
      end
      it "should NOT upload the content" do
        expect(object.has_content?).to be_false
      end
      it "should NOT create an event log" do
        expect(object.event_logs.count).to eq(0)
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
