require 'spec_helper'

describe AttachmentsController, type: :controller, attachments: true do

  let(:attach_to) { FactoryGirl.create(:collection) }
  let(:file) { fixture_file_upload('sample.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:object) { FactoryGirl.create(:attachment) }
  end

  describe "#new" do
    describe "when the user can create an object of this type" do
      before do
        attach_to.roles.grant type: "Curator", agent: user
        attach_to.save!
      end
      it "renders the new template" do
        get :new, attached_to_id: attach_to
        expect(response).to render_template(:new)
      end
    end
    describe "when the user cannot create an object of this type" do
      it "is unauthorized" do
        get :new, attached_to_id: attach_to
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#create" do
    describe "when the user can add attachments to the object" do
      before do
        attach_to.roles.grant type: "Curator", agent: user
        attach_to.save!
      end
      it "persists a new Attachment" do
        expect {
          post :create, attached_to_id: attach_to, content: {file: file},
               descMetadata: {title: ["New Attachment"]}
        }.to change{ Attachment.count }.by(1)
      end
      it "adds the content" do
        post :create, attached_to_id: attach_to, content: {file: file},
             descMetadata: {title: ["New Attachment"]}
        expect(assigns(:current_object)).to have_content
      end
      it "correctly sets the MIME type" do
        post :create, attached_to_id: attach_to, content: {file: file},
             descMetadata: {title: ["New Attachment"]}
        expect(assigns(:current_object).content_type)
          .to eq("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
      end
      it "stores the original file name" do
        post :create, attached_to_id: attach_to, content: {file: file},
             descMetadata: {title: ["New Attachment"]}
        expect(assigns(:current_object).original_filename).to eq("sample.docx")
      end
      it "is attached to the object" do
        post :create, attached_to_id: attach_to, content: {file: file},
             descMetadata: {title: ["New Attachment"]}
        expect(assigns(:current_object).attached_to).to eq(attach_to)
      end
      it "doesn't save an empty string metadata value" do
        post :create, attached_to_id: attach_to, content: {file: file},
             descMetadata: {title: ["New Attachment"], description: [""]}
        expect(assigns(:current_object).dc_description).to be_blank
      end
      it "grants roles to the creator" do
        post :create, attached_to_id: attach_to, content: {file: file},
             descMetadata: {title: ["New Attachment"]}
        expect(assigns(:current_object).roles.granted?(type: "Editor", agent: user.agent, scope: "resource"))
          .to be true
      end
      it "records a creation event" do
        expect {
          post :create, attached_to_id: attach_to, content: {file: file},
               descMetadata: {title: ["New Attachment"]}
        }.to change { Ddr::Events::CreationEvent.count }.by(1)
      end
      it "should redirect after creating the new object" do
        post :create, attached_to_id: attach_to, content: {file: file},
             descMetadata: {title: ["New Attachment"]}
        expect(response).to be_redirect
      end
      describe "and attached_to object is governed by a collection" do
        let(:collection) { FactoryGirl.create(:collection) }
        before do
          attach_to.admin_policy = collection
          attach_to.save
        end
        it "should apply the admin policy to the attachment" do
          post :create, attached_to_id: attach_to, content: {file: file},
               descMetadata: {title: ["New Attachment"]}
          expect(assigns(:current_object).admin_policy).to eq(collection)
        end
      end
      it "should validate the checksum when provided" do
        expect(controller).to receive(:validate_checksum)
        post :create, attached_to_id: attach_to,
             content: {file: file,
                       checksum: "b3f5fc721b5b7ea0c1756a68ed4626463c610170aa199f798fb630ddbea87b18",
                       checksum_type: "SHA-256"},
             descMetadata: {title: ["New Attachment"]}
      end
    end
    describe "user cannot add attachments to object" do
      it "should be unauthorized" do
        post :create, attached_to_id: attach_to, content: {file: file}
        expect(response.response_code).to eq(403)
      end
    end
  end
end
