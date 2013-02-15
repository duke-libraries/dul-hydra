require 'spec_helper'

describe CatalogController do

  let(:user) { FactoryGirl.create(:user) }
  before(:each) { sign_in user }
  after(:all) { user.delete }

  context "#model_index" do
    subject { get :model_index, :model => object.class.to_s }
    after { object.delete }
    context "Collection" do
      let(:object) { FactoryGirl.create(:collection_public_read) }
      it { should render_template(:model_index) }
    end
    context "Item" do
      let(:object) { FactoryGirl.create(:item_public_read) }
      it { should render_template(:model_index) }
    end
    context "Component" do
      let(:object) { FactoryGirl.create(:component_public_read) }
      it { should render_template(:model_index) }
    end
  end

  context "#show" do
    subject { get :show, :id => object }
    after { object.delete }
    context "Collection" do
      let(:object) { FactoryGirl.create(:collection_public_read) }
      it { should render_template(:show) }
    end
    context "Item" do
      let(:object) { FactoryGirl.create(:item_public_read) }
      it { should render_template(:show) }
    end
    context "Component" do
      let(:object) { FactoryGirl.create(:component_public_read) }
      it { should render_template(:show) }
    end
  end

  context "#datastreams" do
    subject { get :datastreams, :object_id => object }
    after { object.delete }
    context "Collection" do
      let(:object) { FactoryGirl.create(:collection_public_read) }
      it { should render_template(:datastreams) }
    end
    context "Item" do
      let(:object) { FactoryGirl.create(:item_public_read) }
      it { should render_template(:datastreams) }
    end
    context "Component" do
      let(:object) { FactoryGirl.create(:component_public_read) }
      it { should render_template(:datastreams) }
    end
  end

  context "#datastream" do
    subject { get :datastream, :object_id => object, :id => dsid }
    after { object.delete }
    let(:dsid) { "DC" }
    context "Collection" do
      let(:object) { FactoryGirl.create(:collection_public_read) }
      it { should render_template(:datastream) }
    end
    context "Item" do
      let(:object) { FactoryGirl.create(:item_public_read) }
      it { should render_template(:datastream) }
    end
    context "Component" do
      let(:object) { FactoryGirl.create(:component_public_read) }
      it { should render_template(:datastream) }
    end
  end

  context "#datastream_content" do
    subject { get :datastream_content, :object_id => object, :id => dsid }
    after { object.delete }
    let(:dsid) { "DC" }
    context "Collection" do
      let(:object) { FactoryGirl.create(:collection_public_read) }
      it { should be_successful }
    end
    context "Item" do
      let(:object) { FactoryGirl.create(:item_public_read) }
      it { should be_successful }
    end
    context "Component" do
      let(:object) { FactoryGirl.create(:component_public_read) }
      it { should be_successful }
    end
    it "should download non-text content as attachment"
  end
end
