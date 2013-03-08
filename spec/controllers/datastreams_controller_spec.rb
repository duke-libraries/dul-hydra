require 'spec_helper'

shared_examples "a datastream profile view" do
  it { should render_template(:show) }
end

describe DatastreamsController do
  after { object.delete }
  context "#show" do
    let(:object) { FactoryGirl.create(:test_model) }
    let(:dsid) { "DC" }
    context "profile information" do
      subject { get :show, :object_id => object, :id => dsid }
      it { should render_template(:show) }
    end
    context "download content" do
      subject { get :show, :object_id => object, :id => dsid, :download => 'true' }
      # XXX more specific expectation
      it { should be_successful }
    end
  end
  context "#thumbnail" do
    subject { get :thumbnail, :object_id => object }
    context "object has thumbnail" do
      let(:object) { FactoryGirl.create(:test_content_thumbnail) }
      it { should be_successful }
    end
    context "object doesn't have thumbnail" do
      let(:object) { FactoryGirl.create(:test_model) }
      it { should_not be_successful }
    end
  end
end
