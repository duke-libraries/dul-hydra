require 'spec_helper'

def create_attachment checksum = "b3f5fc721b5b7ea0c1756a68ed4626463c610170aa199f798fb630ddbea87b18"
  post :create, attach_to: attach_to, attachment: {title: "Attachment", description: ""}, content: fixture_file_upload('sample.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'), checksum: checksum
end

def new_attachment 
  get :new, attach_to: FactoryGirl.create(:collection)
end

describe AttachmentsController, attachments: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:attach_to) { FactoryGirl.create(:collection) }
    let(:create_object) do
      Proc.new do
        attach_to.edit_users = [user.user_key]
        attach_to.save
        create_attachment
      end
    end
    let(:new_object) do
      Proc.new do
        controller.current_ability.can(:add_attachment, attach_to)
        get :new, attach_to: attach_to
      end
    end
  end

  describe "#new" do
    # see shared examples
    describe "when user cannot add attachments to object" do
      let(:attach_to) { FactoryGirl.create(:collection) }
      before do
        controller.current_ability.can(:create, Attachment)
        controller.current_ability.cannot(:add_attachment, attach_to)
      end
      it "should be unauthorized" do
        get :new, attach_to: attach_to
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#create" do
    # see shared examples
    let(:attach_to) { FactoryGirl.create(:collection) }
    describe "when the user can create attachments" do
      before { controller.current_ability.can(:create, Attachment) }
      describe "when user can add attachments to object" do
        before { controller.current_ability.can(:add_attachment, attach_to) }
        it "should create a new object" do
          expect{ create_attachment }.to change{ Attachment.count }.by(1)
        end
        it "should have content" do
          create_attachment
          expect(assigns(:attachment)).to have_content
        end
        it "should correctly set the MIME type" do
          create_attachment
          expect(assigns(:attachment).content_type).to eq("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
        end
        it "should store the original file name" do
          create_attachment
          expect(assigns(:attachment).original_filename).to eq("sample.docx")
        end
        it "should be attached to the object" do
          create_attachment
          expect(assigns(:attachment).attached_to).to eq(attach_to)
        end
        it "should copy the object's permissions to the attachment" do
          pending
          expect(Attachment.any_instance).to receive(:copy_permissions_from)
          create_attachment
          #expect(assigns(:attachment).permissions).to eq(attach_to.permissions)
          #expect(assigns(:attachment).read_users).to include(user.user_key, "sally@example.com", "bob@example.com")
        end
        context "and attached_to object is governed by an admin policy" do
          let(:apo) { FactoryGirl.create(:admin_policy) }
          before do 
            attach_to.admin_policy = apo
            attach_to.save
          end
          it "should apply the admin policy to the attachment" do
            create_attachment
            expect(assigns(:attachment).admin_policy).to eq(apo)
          end
          it "should not copy the permissions of the attached_to object" do
            pending
            expect(Attachment.any_instance).not_to receive(:copy_permissions_from)
            create_attachment
            #expect(assigns(:attachment).read_users).not_to include("sally@example.com")
            #expect(assigns(:attachment).read_users).not_to include("bob@example.com")
          end
        end
        context "and the checksum doesn't match" do
          it "should not create a new object" do
            expect{ create_attachment checksum = "5a2b997867b99ef10ed02aab1e406a798a71f5f630aeeca5ebdf443d4d62bcd1" }.not_to change{ Attachment.count }
          end
          it "should not create an event log" do
            expect{ create_attachment checksum = "5a2b997867b99ef10ed02aab1e406a798a71f5f630aeeca5ebdf443d4d62bcd1" }.not_to change{ EventLog.where(model: "Attachment", action: EventLog::Actions::CREATE).count }
          end
        end
      end
    end
    describe "user cannot add attachments to object" do
      before { controller.current_ability.cannot(:add_attachment, attach_to) }
      it "should be unauthorized" do
        create_attachment
        expect(response.response_code).to eq(403)
      end
    end
  end
end
