require 'spec_helper'
require 'zip/zip'

describe ExportSetsController, type: :controller, export_sets: true do
  before { sign_in user }
  context "#index" do
    let(:user) { FactoryGirl.create(:user) }
    it "should display the user's list of export sets" do
      get :index
      expect(response).to render_template(:index)
    end
  end
  context "#new" do
    let(:user) { FactoryGirl.create(:user) }
    context "valid export type" do
      it "should render the :new template" do
        get :new, export_type: ExportSet::Types::CONTENT
        expect(response).to render_template(:new)
      end
    end
    context "missing or invalid export type" do
      before { request.env["HTTP_REFERER"] = export_sets_url }
      it "should redirect back" do
        get :new
        expect(response).to be_redirect
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
    it "should create an export set and redirect to the show page" do
      expect(user.export_sets.count).to eq(0)
      post :create, :export_set => {:pids => [object.pid], :export_type => ExportSet::Types::CONTENT}
      expect(user.export_sets.count).to eq(1)
      expect(response).to redirect_to(export_set_path(assigns[:export_set]))
    end
  end
  context "#update" do
    context "content export set" do
      let(:export_set) { FactoryGirl.create(:content_export_set, :pids => ["foo:bar"]) }
      let(:user) { export_set.user }
      it "should change the title" do
        put :update, :id => export_set, :export_set => {:title => "Title Changed"}
        expect(export_set.reload.title).to eq("Title Changed")
        expect(response).to redirect_to(export_set_path(export_set))
      end
    end
    context "metadata export set" do
      let(:export_set) { FactoryGirl.create(:descriptive_metadata_export_set_with_pids, :csv_col_sep => "tab") }
      let(:user) { export_set.user }
      before do
        export_set.archive = File.new(File.join(Rails.root, 'spec', 'fixtures', 'csv_processing', 'simple.csv'))
        export_set.save!
      end
      context "csv col sep unchanged" do
        it "should not delete the archive file" do
          put :update, :id => export_set, :export_set => {:csv_col_sep => "tab"}
          expect(export_set.reload.archive_file_name).to eq('simple.csv')
          expect(response).to redirect_to(export_set_path(export_set))
        end
      end
      context "csv col sep changed" do
        it "should delete the archive file" do
          put :update, :id => export_set, :export_set => {:csv_col_sep => "comma"}
          expect(export_set.reload.archive_file_name).to be_nil
          expect(response).to redirect_to(export_set_path(export_set))
        end
      end
    end
  end
  context "#destroy" do
    let(:export_set) { FactoryGirl.create(:content_export_set, :pids => ["foo:bar"]) }
    let(:user) { export_set.user }
    it "should delete the export set and redirect to the index page" do
      delete :destroy, :id => export_set
      expect { ExportSet.find(export_set.id) }.to raise_error(ActiveRecord::RecordNotFound)
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
    context "request method == delete" do
      before { export_set.create_archive }
      it "should delete the archive and redirect to the show page" do
        delete :archive, :id => export_set
        expect(export_set.reload.archive?).to be_falsey
        expect(response).to redirect_to(export_set_path(export_set))
      end
    end
    context "request method == patch" do
      it "should create the archive" do
        expect(export_set.archive_file_name).to be_nil
        patch :archive, :id => export_set
        expect(export_set.reload.archive?).to be_truthy
        expect(response).to redirect_to(export_set_path(export_set))
      end
    end
  end
end
