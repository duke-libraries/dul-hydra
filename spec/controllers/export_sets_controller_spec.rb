require 'spec_helper'
require 'zip/zip'

describe ExportSetsController do
  context "#index" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }
    after { user.delete }    
    it "should display the user's list of export sets" do
      get :index
      response.should render_template(:index)
    end
  end
  context "#new" do
    let(:user) { FactoryGirl.create(:user) }
    let(:object_read) { FactoryGirl.create(:test_content) }
    let(:object_discover) { FactoryGirl.create(:test_content) }
    before do
      object_read.read_users = [user.username]
      object_read.save
      object_discover.discover_users = [user.username]
      object_discover.save
      sign_in user      
    end
    after do
      object_read.delete 
      object_discover.delete 
      user.delete
    end
    it "should list bookmarks for content-bearing objects on which user has read permission" do
      pending "Figuring out how to create bookmarks"
      user.bookmarks.size.should == 2
      get :new
      response.should render_template(:new)
      assigns(:documents).size.should == 1
    end
  end
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
        arch.find_entry(DulHydra.export_set_manifest_file_name).should_not be_nil
        arch.find_entry(DulHydra.export_set_manifest_file_name).get_input_stream().read.should \
            include(object.datastreams[DulHydra::Datastreams::CONTENT].checksum)
        arch.find_entry(DulHydra.export_set_manifest_file_name).get_input_stream().read.should \
            include(object.datastreams[DulHydra::Datastreams::CONTENT].checksumType)
      end
    end
  end
  context "#update" do
    let(:export_set) { FactoryGirl.create(:export_set, :pids => ["foo:bar"]) }
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
    let(:export_set) { FactoryGirl.create(:export_set, :pids => ["foo:bar"]) }
    it "should delete the export set and redirect to the index page" do
      delete :destroy, :id => export_set
      lambda { ExportSet.find(export_set.id) }.should raise_error(ActiveRecord::RecordNotFound)
      expect(subject).to redirect_to(export_sets_path)
    end
  end
  context "#archive" do 
    let(:object) { FactoryGirl.create(:test_content) }
    let(:export_set) { FactoryGirl.create(:export_set, :pids => [object.pid]) }
    before do 
      sign_in export_set.user
    end
    after do
      object.delete
      export_set.user.delete
    end
    context "request method == delete" do
      before { export_set.create_archive }
      it "should delete the archive and redirect to the show page" do
        export_set.archive_file_name.should_not be_nil
        delete :archive, :id => export_set
        export_set.reload.archive_file_name.should be_nil
        response.should redirect_to(export_set_path(export_set))
      end
    end
    context "request method == post" do
      it "should create the archive" do
        export_set.archive_file_name.should be_nil
        post :archive, :id => export_set
        export_set.reload.archive_file_name.should_not be_nil
        response.should redirect_to(export_set_path(export_set))
      end
    end
  end
end
