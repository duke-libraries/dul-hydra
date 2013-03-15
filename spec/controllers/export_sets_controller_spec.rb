require 'spec_helper'

describe ExportSetsController do
  context "#create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:object) { FactoryGirl.create(:test_content) }
    before { sign_in user }
    after { user.delete }
    it "should create an export set and redirect to the show page" do
      user.export_sets.count.should == 0
      post :create, :export_set => {:pids => [object.pid]}
      user.export_sets.count.should == 1
      expect(response).to redirect_to(export_set_path(assigns[:export_set]))
    end
  end
  context "#update" do
    subject { put :update, :id => export_set, :export_set => {:title => "Title Changed"} }
    let(:export_set) { FactoryGirl.create(:export_set) }
    before { sign_in export_set.user }
    after { export_set.user.delete }
    it "should change the title" do
      export_set.title.should = "Title Changed"
      expect(subject).to redirect_to(export_set_path(export_set))
    end
  end
  context "#destroy" do
    subject { delete :destroy, :id => export_set }
    before { sign_in export_set.user }
    after { export_set.user.delete }
    it "should delete the export set and redirect to the index page" do
      expect(subject).to redirect_to(export_sets_path)
    end
  end
end
