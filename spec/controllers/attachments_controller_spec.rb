require 'spec_helper'

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
        post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx')
        expect(assigns(:attachment)).to have_content
      end
      it "should have metadata" do
        post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx')
        expect(assigns(:attachment).title).to eq(["Attachment"])
        expect(assigns(:attachment).description).to eq(["Sample file"])
        expect(assigns(:attachment).source).to eq(["sample.docx"])
      end
      it "should be attached to the object" do
        post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx')
        expect(assigns(:attachment).attached_to).to eq(obj)
      end
      it "should copy the object's permissions to the attachment" do
        post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx')
        expect(assigns(:attachment).permissions).to eq(obj.permissions)
      end
      it "should redirect to the object show action" do
        post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx')
        expect(response).to redirect_to(controller: 'objects', action: 'show', id: obj, tab: 'attachments')
      end
      context "attached_to object is governed by an admin policy" do
        let(:apo) { FactoryGirl.create(:admin_policy) }
        before do 
          obj.admin_policy = apo
          obj.save!
        end
        it "should apply the admin policy to the attachment" do
          post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx')
          expect(assigns(:attachment).admin_policy).to eq(apo)
        end
      end
    end
    describe "user cannot add attachments to object" do
      subject { post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx') }
      before { controller.current_ability.cannot(:add_attachment, obj) }
      its(:response_code) { should == 403 }
    end
  end
end
