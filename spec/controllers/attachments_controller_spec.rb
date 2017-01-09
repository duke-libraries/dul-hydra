require 'spec_helper'

def create_attachment opts={}
  checksum, checksum_type = opts.values_at(:checksum, :checksum_type)
  post :create, attached_to_id: attach_to.pid, content: {file: fixture_file_upload('sample.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'), checksum: checksum, checksum_type: checksum_type}, descMetadata: {title: ["New Attachment"]}
end

describe AttachmentsController, type: :controller, attachments: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:attach_to) { FactoryGirl.create(:collection) }
    let(:create_object) do
      Proc.new do
        attach_to.roles.grant type: "Contributor", agent: user
        attach_to.save!
        create_attachment
      end
    end
    let(:new_object) do
      Proc.new do
        attach_to.roles.grant type: "Contributor", agent: user
        attach_to.save!
        get :new, attached_to_id: attach_to.pid
      end
    end
  end

  describe "#new" do
    # see shared examples
    describe "when user cannot add attachments to object" do
      let(:attach_to) { FactoryGirl.create(:collection) }
      it "should be unauthorized" do
        get :new, attached_to_id: attach_to.pid
        expect(response.response_code).to eq(403)
      end
    end
  end

  describe "#create" do
    # see shared examples
    let(:attach_to) { FactoryGirl.create(:collection) }
    describe "when user can add attachments to object" do
      before do
        attach_to.roles.grant type: "Contributor", agent: user
        attach_to.save!
      end
      it "should create a new object" do
        expect{ create_attachment }.to change{ Attachment.count }.by(1)
      end
      it "should have content" do
        create_attachment
        expect(assigns(:current_object)).to have_content
      end
      it "should correctly set the MIME type" do
        create_attachment
        expect(assigns(:current_object).content_type).to eq("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
      end
      it "should store the original file name" do
        create_attachment
        expect(assigns(:current_object).original_filename).to eq("sample.docx")
      end
      it "should be attached to the object" do
        create_attachment
        expect(assigns(:current_object).attached_to).to eq(attach_to)
      end
      context "and attached_to object is governed by a collection" do
        let(:collection) { FactoryGirl.create(:collection) }
        before do
          attach_to.admin_policy = collection
          attach_to.save
        end
        it "should apply the admin policy to the attachment" do
          create_attachment
          expect(assigns(:current_object).admin_policy).to eq(collection)
        end
      end
      it "should validate the checksum when provided" do
        expect(controller).to receive(:validate_checksum)
        create_attachment(checksum: "ff01aab0eada29d35bb423c5c73a9f67a22bc1fd", checksum_type: "SHA-1")
      end
    end
    describe "user cannot add attachments to object" do
      it "should be unauthorized" do
        create_attachment
        expect(response.response_code).to eq(403)
      end
    end
  end
end
