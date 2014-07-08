require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Components views", components: true do

  describe "show" do
    context "basic" do
      let(:object) { FactoryGirl.create(:component) }
      it_behaves_like "a repository object show view"
    end
    context "content-bearing" do
      let(:object) { FactoryGirl.create(:component_with_content) }
      it_behaves_like "a content-bearing object show view"
    end
    context "has parent" do
      let(:object) { FactoryGirl.create(:component_has_parent) }
      it_behaves_like "a child object show view"
    end
  end

  describe "edit/update" do
    let(:object) { FactoryGirl.create(:component) }
    it_behaves_like "a repository object descriptive metadata editing view"
  end

  describe "permissions" do
    let(:object) { FactoryGirl.create(:component) }
    it_behaves_like "a governable repository object rights editing view"
  end

end
