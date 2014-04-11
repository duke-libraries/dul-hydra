require 'spec_helper'

describe CatalogController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  after { user.destroy }
  it "should use HTTP POST for Solr" do
    expect(controller.blacklight_config.http_method).to eq(:post)
  end
end
