require 'spec_helper'
require 'zip/zip'

describe ExportSetsController do
  context "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:object) { FactoryGirl.create(:test_content) }
    before { sign_in user }
    after { user.delete; object.delete }
    it "should create an export set and redirect to the show page" do
      user.export_sets.count.should == 0
      post :create, :export_set => {:pids => [object.pid]}
      user.export_sets.count.should == 1
      expect(response).to redirect_to(export_set_path(assigns[:export_set]))
      Zip::ZipFile.open(assigns[:export_set].archive.path) do |arch|
        arch.find_entry(ExportSet::MANIFEST_FILE_NAME).should_not be_nil
        arch.find_entry(ExportSet::MANIFEST_FILE_NAME).get_input_stream().read.should \
            include(object.datastreams[DulHydra::Datastreams::CONTENT].checksum)
        arch.find_entry(ExportSet::MANIFEST_FILE_NAME).get_input_stream().read.should \
            include(object.datastreams[DulHydra::Datastreams::CONTENT].checksumType)
      end
    end
  end
  context "#update" do
    let(:export_set) { FactoryGirl.create(:export_set) }
    before { sign_in export_set.user }
    after { export_set.user.delete }
    it "should change the title" do
      put :update, :id => export_set, :export_set => {:title => "Title Changed"}
      export_set.reload.title.should == "Title Changed"
      expect(response).to redirect_to(export_set_path(export_set))
    end
  end
  context "#destroy" do
    before { sign_in export_set.user }
    let(:export_set) { FactoryGirl.create(:export_set) }
    it "should delete the export set and redirect to the index page" do
      delete :destroy, :id => export_set
      lambda { ExportSet.find(export_set.id) }.should raise_error(ActiveRecord::RecordNotFound)
      expect(subject).to redirect_to(export_sets_path)
    end
  end
  context "#archive" do 
    let(:export_set) { FactoryGirl.create(:export_set) }
    let(:object) { FactoryGirl.create(:test_content) }
    before do 
      sign_in export_set.user
      export_set.pids = [object.pid]
      export_set.create_archive
    end
    after do
      object.delete
      export_set.user.delete
    end
    it "should delete the archive and redirect to the show page" do
      delete :archive, :id => export_set
      export_set.reload.archive_file_name.should be_nil
      response.should redirect_to(export_set_path(export_set))
    end
  end
end
