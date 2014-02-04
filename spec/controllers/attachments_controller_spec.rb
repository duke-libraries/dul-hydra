require 'spec_helper'

describe AttachmentsController, attachments: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:obj) { FactoryGirl.create(:test_model) }
  before { sign_in user }
  after do
    user.destroy
    obj.destroy
    @attachment.destroy if @attachment
  end
  describe "#new" do
    describe "user can add attachments to object" do
      before do
        obj.edit_users = [user.user_key]
        obj.save!
      end
      it "should render the :new template" do
        get :new, id: obj
        response.should be_successful
      end
    end
    describe "user cannot add attachments to object" do
      before { controller.current_ability.cannot(:add_attachment, obj) }
      it "should return unauthorized" do
        get :new, id: obj
        response.response_code.should == 403
      end
    end
  end
  describe "#create" do
    describe "user can add attachments to object" do
      before do
        obj.edit_users = [user.user_key]
        obj.save!
      end
      it "should create the attachments, attach to object and redirect" do
        post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx')
        @attachment = Attachment.find(assigns(:attachment).pid)
        @attachment.title.should == ["Attachment"]
        @attachment.description.should == ["Sample file"]
        @attachment.source.should == ["sample.docx"]
        @attachment.content.size.should == File.size('spec/fixtures/sample.docx')
        @attachment.attached_to.should == obj
        @attachment.permissions.should == obj.permissions
        response.should redirect_to(controller: 'objects', action: 'show', id: obj, tab: 'attachments')
      end
      context "attached_to object is governed by an admin policy" do
        let(:apo) { FactoryGirl.create(:admin_policy) }
        before do
          obj.admin_policy = apo
          obj.save!
        end
        after { apo.destroy }
        it "should set the admin policy of the attachment to the object's admin policy" do
          post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx')
          assigns(:attachment).admin_policy.should == apo
        end
      end
    end
    describe "user cannot add attachments to object" do
      before { controller.current_ability.cannot(:add_attachment, obj) }
      it "should return unauthorized" do
        post :create, id: obj, attachment: {title: "Attachment", description: "Sample file"}, content: fixture_file_upload('sample.docx')
        response.response_code.should == 403
      end
    end
  end
end
