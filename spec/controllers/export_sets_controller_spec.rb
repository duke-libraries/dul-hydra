require 'spec_helper'
require 'zip/zip'

describe ExportSetsController, export_sets: true do
  before { sign_in user }
  after { user.destroy }    
  context "#index" do
    let(:user) { FactoryGirl.create(:user) }
    it "should display the user's list of export sets" do
      get :index
      response.should render_template(:index)
    end
  end
  context "#new" do
    let(:user) { FactoryGirl.create(:user) }
    context "valid export type" do
      it "should render the :new template" do
        get :new, export_type: ExportSet::Types::CONTENT
        response.should render_template(:new)
      end
    end
    context "missing or invalid export type" do
      before { request.env["HTTP_REFERER"] = export_sets_url }
      it "should redirect back" do
        get :new
        response.should be_redirect
      end
    end
  end
  context "#create" do
    let(:object) { FactoryGirl.create(:test_content) }
    let(:user) { FactoryGirl.create(:user) }
    before do
      object.read_users = [user.user_key]
      object.save
    end
    after do
      object.delete
    end
    it "should create an export set and redirect to the show page" do
      user.export_sets.count.should == 0
      post :create, :export_set => {:pids => [object.pid], :export_type => ExportSet::Types::CONTENT}
      user.export_sets.count.should == 1
      expect(response).to redirect_to(export_set_path(assigns[:export_set]))
    end
  end
  context "#update" do
    let(:export_set) { FactoryGirl.create(:content_export_set, :pids => ["foo:bar"]) }
    let(:user) { export_set.user }
    it "should change the title" do
      put :update, :id => export_set, :export_set => {:title => "Title Changed"}
      export_set.reload.title.should == "Title Changed"
      expect(response).to redirect_to(export_set_path(export_set))
    end
  end
  context "#destroy" do
    let(:export_set) { FactoryGirl.create(:content_export_set, :pids => ["foo:bar"]) }
    let(:user) { export_set.user }
    it "should delete the export set and redirect to the index page" do
      delete :destroy, :id => export_set
      lambda { ExportSet.find(export_set.id) }.should raise_error(ActiveRecord::RecordNotFound)
      expect(subject).to redirect_to(export_sets_path)
    end
  end
  context "#archive" do 
    let(:object) { FactoryGirl.create(:test_content) }
    let(:export_set) { FactoryGirl.create(:content_export_set, :pids => [object.pid]) }
    let(:user) { export_set.user }
    before do 
      object.read_users = [user.user_key]
      object.save
    end
    after do
      object.delete
    end
    context "request method == delete" do
      before { export_set.create_archive }
      it "should delete the archive and redirect to the show page" do
        delete :archive, :id => export_set
        export_set.reload.archive?.should be_false
        response.should redirect_to(export_set_path(export_set))
      end
    end
    context "request method == patch" do
      it "should create the archive" do
        export_set.archive_file_name.should be_nil
        patch :archive, :id => export_set
        export_set.reload.archive?.should be_true
        response.should redirect_to(export_set_path(export_set))
      end
    end
  end
end
