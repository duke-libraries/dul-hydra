require 'spec_helper'
require 'helpers/user_helper'

describe "batches/index.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  context "logged in user" do
    before do
      login user
    end
    after { user.delete }
    context "user has no permitted ingest folders" do
      before do
        IngestFolder.stub(:permitted_folders).with(user).and_return(nil)
        visit batches_path
      end
      it "should not include a link to create an ingest folder" do
        expect(page).to_not have_button(I18n.t('batch.ingest_folder.create'))
      end
    end
    context "user has permitted ingest folders" do
      before do
        IngestFolder.stub(:permitted_folders).with(user).and_return(["/base/path/"])
        visit batches_path
      end
      it "should include a link to create an ingest folder" do
        expect(page).to have_button(I18n.t('batch.ingest_folder.create'))
      end
    end
  end
end