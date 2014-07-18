require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Items views", items: true do

  describe "show" do
    context "basic" do
      let(:object) { FactoryGirl.create(:item) }
      it_behaves_like "a repository object show view"
    end
    context "has parent" do
      let(:object) { FactoryGirl.create(:item_in_collection) }
      it_behaves_like "a child object show view"
    end
  end

  describe "edit/update" do
    let(:object) { FactoryGirl.create(:item) }
    it_behaves_like "a repository object descriptive metadata editing view"
  end

  describe "permissions" do
    let(:object) { FactoryGirl.create(:item) }
    it_behaves_like "a governable repository object rights editing view"
  end

end
