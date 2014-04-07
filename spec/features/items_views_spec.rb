require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Items views" do
  let(:object) { FactoryGirl.create(:item) }
  describe "show" do
    it_behaves_like "a repository object show view"
  end
  describe "rights editing" do
    it_behaves_like "a repository object rights editing view"
  end
end
