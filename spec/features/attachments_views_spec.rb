require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Attachments views" do
  let(:object) { FactoryGirl.create(:attachment) }
  describe "show" do
    it_behaves_like "a repository object show view"
    it_behaves_like "a content-bearing object show view"
  end
  describe "rights editing" do
    it_behaves_like "a repository object rights editing view"
  end
end
