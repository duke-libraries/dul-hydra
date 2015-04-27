require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Items views", type: :feature, items: true do

  describe "show" do
    context "basic" do
      let(:object) { FactoryGirl.create(:item) }
      it_behaves_like "a repository object show view"
    end
    context "has parent" do
      let(:object) { FactoryGirl.create(:item, :member_of_collection) }
      it_behaves_like "a child object show view"
    end
  end

  describe "new/create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:parent) { FactoryGirl.create(:collection) }
    context "without a component" do
      it "should create a new item" do
        skip "Can't find form field -- help me write this test!"
        visit new_item_path(parent_id: parent.pid)
        fill_in "descMetadata__title__0", with: "New Item"
        click_button "Create Item"
        parent.reload
        expect(parent.children.first).to be_a(Item)
        expect(parent.children.first.title).to eq(["New Item"])
      end
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
