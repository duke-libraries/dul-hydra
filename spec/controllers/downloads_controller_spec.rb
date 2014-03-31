require 'spec_helper'

describe DownloadsController do
  let(:user) { FactoryGirl.create(:user) }
  after do
    user.destroy
    obj.destroy
  end
  before do
    obj.read_users = [user.user_key]
    obj.save
    sign_in user
  end
  context "object (i.e. content) download" do
    let(:obj) { FactoryGirl.create(:test_content) }
    it "should download successfully" do
      get :show, id: obj
      expect(response).to be_successful
    end
    context "when original_filename is set" do
      it "should attach the file using the original filename" do
        get :show, id: obj
        #expect(obj.content).to be_present
        #expect(obj.content.size).to eq(10032)
        #expect(obj.original_filename).to eq("library-devil.tiff")
        expect(response.headers["Content-Disposition"]).to match(/filename="#{obj.original_filename}"/)
      end
    end
    context "when original_filename is not set" do
      before { obj.original_filename = nil; obj.save! }
      context "but identifier is set to what looks like a file name" do
        let(:filename) { [obj.identifier.first, obj.content.default_file_extension].join(".") }
        it "should attach the file using the identifier as a file prefix" do
          get :show, id: obj
          expect(response.headers["Content-Disposition"]).to match(/filename="#{filename}"/)
        end
      end
      context "and identifier is not set to what looks like a file name" do
        before { obj.identifier = "This doesn't look like a file name"; obj.save }
        it "should attach the file using a default file name" do
          get :show, id: obj
          expect(response.headers["Content-Disposition"]).to match(/filename="#{obj.content.default_file_name}"/)
        end
      end
    end
  end
  context "descMetadata download" do
    let(:obj) { FactoryGirl.create(:collection) }
    it "should download successfully" do
      get :show, id: obj, datastream_id: "descMetadata"
      response.should be_successful
    end
  end
  context "rightsMetadata download" do
    let(:obj) { FactoryGirl.create(:admin_policy) }
    it "should download successfully" do
      get :show, id: obj, datastream_id: "rightsMetadata"
      response.should be_successful
    end
  end
end
