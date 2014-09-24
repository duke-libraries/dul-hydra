require 'spec_helper'

describe CatalogController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  it "should use HTTP POST for Solr" do
    expect(controller.blacklight_config.http_method).to eq(:post)
  end
end
