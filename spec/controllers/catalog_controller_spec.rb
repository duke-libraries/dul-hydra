require 'spec_helper'

describe CatalogController do
  render_views
  let(:user) { FactoryGirl.create(:user) }
  after(:all) { user.delete }
  before(:each) { sign_in user }
  after(:each) { sign_out user }
  context "#show" do
    subject { get :show, :id => object }
    after { object.delete }
    context "basic rendering" do
      let(:object) { FactoryGirl.create(:test_model) }
      it { should render_template(:show) }
      it { should render_template(:partial => '_show_permissions') }
    end
    context "object is describable" do
      let(:object) { FactoryGirl.create(:test_model) }
      it { should render_template(:partial => '_show_metadata') }
    end
    context "object is not describable" do
      let(:object) { PreservationEvent.create }
      before do
        object.read_groups = ["public"]
        object.save!
      end
      it { should_not render_template(:partial => '_show_metadata') }
    end
    context "object has children" do
      let(:object) { FactoryGirl.create(:item_public_read) }
      before do
        object.children << FactoryGirl.create(:component_public_read)
      end
      after do
        object.children.each {|c| c.delete}
        object.reload
      end
      it { should render_template(:partial => '_show_children') }
      it { should_not render_template(:partial => '_show_content') }
    end
    context "object does not have children" do
      let(:object) { FactoryGirl.create(:component_public_read) }
      it { should_not render_template(:partial => '_show_children') }
      it { should render_template(:partial => '_show_content') }
    end
    context "object is a collection" do
      let(:object) { FactoryGirl.create(:collection_public_read) }
      it { should render_template(:partial => '_show_collection_info') }
    end
    context "object is not a collection" do
      let(:object) { FactoryGirl.create(:item_public_read) }
      it { should_not render_template(:partial => '_show_collection_info') }
    end
  end
end
