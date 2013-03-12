require 'spec_helper'

describe ThumbnailController do
  after { object.delete }
  context "#show" do
    subject { get :show, :object_id => object }
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
