require 'spec_helper'

describe ExportSetsController do
  context "#create" do
    subject { post :create, :export_set => {:pids => [object.pid]} }
    let(:user) { FactoryGirl.create(:user) }
    let(:object) { FactoryGirl.create(:test_content) }
    before { sign_in user }
    after { user.delete }
    it "should create an export set and redirect to the show page" do
      user.export_sets.should_not be_empty
      expect(subject).to redirect_to(:show)
    end
  end
  context "#destroy" do
    subject { delete :destroy, :id => export_set }
    let(:export_set) { FactoryGirl.create(:export_set) }
    before { sign_in export_set.user }
    after { export_set.user.delete }
    it "should delete the export set and redirect to the index page" do
      expect(subject).to redirect_to(export_sets_path)
    end
  end
end
