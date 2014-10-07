require 'spec_helper'

describe "catalog/index.html.erb", :type => :feature do
  let(:user) { FactoryGirl.create(:user) }
  let(:object) { FactoryGirl.create(:component) }
  before(:each) { login_as user }
  describe "footer" do
    before { visit catalog_index_path }
    it "has a help link" do
      expect(page).to have_link(I18n.t('dul_hydra.help.label'), help_path)
    end
    it "has a contact link" do
      expect(page).to have_link(I18n.t('dul_hydra.contact.label'), "mailto:#{DulHydra.contact_email}")
    end
  end
  describe "facet results" do
    let(:collection1) { FactoryGirl.create(:collection, title: ["XYZ"]) }
    let(:collection2) { FactoryGirl.create(:collection, title: ["ABC"]) }
    before do
      collection1.discover_groups = ["public"]
      collection1.save!
      collection2.discover_groups = ["public"]
      collection2.save!
      visit catalog_index_path
      click_link "Collection"
    end
    it "should display the results in title order" do
      expect("ABC").to appear_before("XYZ")
    end
    it "should have 'Title' in the sort selector" do
      expect(page).to have_button("Sort by Title")
    end
  end
  describe "search options" do
    before do
      object.discover_groups = ["public"]
      object.save
      visit catalog_index_path
      select "PID", :from => "search_field"
      fill_in "q", :with => object.pid
      click_button "search"
    end
    it "should allow searching by PID" do
      expect(page).to have_content(object.title.first)
    end
  end
  describe "search results" do
    context "general discovery" do
      before do
        object.discover_groups = ["public"]
        object.save!
        visit catalog_index_path
        fill_in "q", :with => object.title.first
        click_button "search"
      end
      it "should display the thumbnail" do
        skip
        expect(page).to have_xpath("//img[@src = '#{thumbnail_path(object)}']")
      end
      it "should display the title and identifier" do
        expect(page).to have_content(object.identifier.first)
        expect(page).to have_content(object.title.first)
      end
    end
    context "user does not have read permission on object" do
      before do
        object.discover_groups = ["public"]
        object.save!
        visit catalog_index_path
        fill_in "q", :with => object.title.first
        click_button "search"
      end
      it "should not link to download or show view" do
        expect(page).not_to have_xpath("//a[@href = \"#{url_for(object)}\"]")
        expect(page).not_to have_xpath("//a[@href = \"#{url_for(controller: 'downloads', action: 'show', id: object)}\"]")
      end
    end
    context "user has read permission on object" do
      before do
        object.read_groups = ["public"]
        object.save!
        visit catalog_index_path
        fill_in "q", :with => object.title.first
        click_button "search"
      end
      it "should link to download and show view" do
        skip "Figure out why this test is failing"
        expect(page).to have_xpath("//a[@href = \"#{url_for(object)}\"]")
        expect(page).to have_xpath("//a[@href = \"#{url_for(controller: 'downloads', action: 'show', id: object)}\"]")
      end
    end
    context "user is superuser" do
      before do
        allow_any_instance_of(User).to receive(:superuser?).and_return(true)
        visit catalog_index_path
        fill_in "q", :with => object.title.first
        click_button "search"
      end
      it "should discover the object" do
        expect(page).to have_content(object.pid)
      end
    end
  end
end
