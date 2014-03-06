require 'spec_helper'

def create_attachment
  post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.pdf', 'application/pdf')
end

describe AttachmentsController, attachments: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:obj) { FactoryGirl.create(:test_model_omnibus) }
  before do
    sign_in user
    obj.read_users = [user.user_key]
    obj.save!
    controller.current_ability.can(:create, Attachment)
  end
  after do
    User.destroy_all
    ActiveFedora::Base.destroy_all
  end
  describe "#new" do
    describe "user can add attachments to object" do
      before { controller.current_ability.can(:add_attachment, obj) }
      it "should render the new template" do
        get :new, id: obj
        expect(response).to render_template(:new)
      end
    end
    describe "user cannot add attachments to object" do
      before { controller.current_ability.cannot(:add_attachment, obj) }
      it "should be unauthorized" do
        get :new, id: obj
        expect(response.response_code).to eq(403)
      end
    end
  end
  describe "#create" do
    describe "user can add attachments to object" do
      before do
        controller.current_ability.can(:add_attachment, obj)
      end
      it "should have content" do
        create_attachment
        expect(assigns(:attachment)).to have_content
        expect(assigns(:attachment).content.size).to eq(83777)
      end
      it "should correctly set the MIME type" do
        create_attachment
        expect(assigns(:attachment).content_type).to eq("application/pdf")
      end
      it "should have metadata" do
        create_attachment
        expect(assigns(:attachment).title).to eq(["Attachment"])
        expect(assigns(:attachment).description).to eq(["Sample file"])
      end
      it "should store the original file name" do
        create_attachment
        expect(assigns(:attachment).original_filename).to eq("sample.pdf")
      end
      it "should be attached to the object" do
        create_attachment
        expect(assigns(:attachment).attached_to).to eq(obj)
      end
      it "should copy the object's permissions to the attachment" do
        create_attachment
        expect(assigns(:attachment).permissions).to eq(obj.permissions)
      end
      it "should redirect to the object show action" do
        create_attachment
        expect(response).to redirect_to(controller: 'objects', action: 'show', id: obj, tab: 'attachments')
      end
      it "should create an event log" do
        create_attachment
        expect(assigns(:attachment).event_logs(action: "create").count).to eq(1)
      end
      context "attached_to object is governed by an admin policy" do
        let(:apo) { FactoryGirl.create(:admin_policy) }
        before do 
          obj.admin_policy = apo
          obj.save!
        end
        it "should apply the admin policy to the attachment" do
          create_attachment
          expect(assigns(:attachment).admin_policy).to eq(apo)
        end
      end
    end
    describe "user cannot add attachments to object" do
      before do 
        controller.current_ability.cannot(:add_attachment, obj)
      end
      it "should be unauthorized" do
        create_attachment
        expect(response.response_code).to eq(403)
      end
    end
  end
end
