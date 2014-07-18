require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Targets views", targets: true do
  let(:object) { FactoryGirl.create(:target) }
  describe "show" do
    it_behaves_like "a repository object show view"
    it_behaves_like "a content-bearing object show view"
  end
  describe "permissions" do
    it_behaves_like "a governable repository object rights editing view"
  end
  describe "edit" do
    it_behaves_like "a repository object descriptive metadata editing view"
  end
end
