require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Attachments views", attachments: true do
  let(:object) { FactoryGirl.create(:attachment) }
  describe "show" do
    it_behaves_like "a repository object show view"
    it_behaves_like "a content-bearing object show view"
  end
  describe "edit" do
    it_behaves_like "a repository object descriptive metadata editing view"
  end
  describe "permissions" do
    it_behaves_like "a governable repository object rights editing view"
  end
end
