require 'spec_helper'
require 'support/shared_examples_for_repository_views'

describe "Collections views", type: :feature, collections: true do

  describe "show" do
    let(:object) { FactoryGirl.create(:collection) }
    it_behaves_like "a repository object show view"

    context "when the collection has related objects" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        object.read_users = [user.user_key]
        object.save
        login_as user
      end
      context "including items" do
        let(:items) { FactoryGirl.create_list(:item, 3) }
        before do
          object.children = items
          object.save
        end
        it "should link to its items" do
          visit collection_path(object)
          expect(page).to have_link "Items"
        end
      end
      context "including attachments" do
        before do
          attachment = Attachment.new
          attachment.attached_to = object
          attachment.save(validate: false)
        end
        it "should link to its attachments" do
          visit collection_path(object)
          expect(page).to have_link "Attachments"
        end
      end
    end
  end

  describe "edit/update" do
    let(:object) { FactoryGirl.create(:collection) }
    it_behaves_like "a repository object descriptive metadata editing view"
  end

  describe "permissions" do
    let(:object) { FactoryGirl.create(:collection) }
    it_behaves_like "a governable repository object rights editing view"
  end

  describe "new/create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:collection_creator) { Role.new("Collection Creator", ability: :create, model: "Collection") }
    before do
      allow_any_instance_of(User).to receive(:roles) { [collection_creator] }
      login_as user
    end
    it "should create a collection" do
      skip "Figuring out how to write the test"
      visit new_collection_path
      fill_in 'Title', with: 'New Collection'
      click_button 'Create Collection'
      expect(page).to have_text("New Collection")
    end
  end
end
