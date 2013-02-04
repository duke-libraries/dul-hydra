require 'spec_helper'

describe CatalogController do
  subject { get :show, :id => item }
  let(:item) { FactoryGirl.create(:item) }
  let(:apo) { FactoryGirl.create(:public_read_policy) }
  before do
    item.admin_policy = apo
    item.save!
    sign_in user
  end
  after do
    sign_out user
    user.delete
    apo.delete
    item.delete
  end
  context "registered user" do
    let(:user) { FactoryGirl.create(:user) }
    it { should render_template(:show) }
  end
  context "editor" do
    let(:user) { FactoryGirl.create(:editor) }
    it { should render_template(:show) }
  end
end
