require 'spec_helper'

describe "catalog/index.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  let(:object) { FactoryGirl.create(:component_with_content) }
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
      page.should have_content(object.title.first)
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
        pending
        page.should have_xpath("//img[@src = '#{thumbnail_path(object)}']")
      end
      it "should display the title and identifier" do
        page.should have_content(object.identifier.first)
        page.should have_content(object.title.first)
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
        page.should_not have_xpath("//a[@href = \"#{url_for(object)}\"]")
        page.should_not have_xpath("//a[@href = \"#{url_for(controller: 'downloads', action: 'show', id: object)}\"]")
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
        pending "Figure out why this test is failing"
        page.should have_xpath("//a[@href = \"#{url_for(object)}\"]")
        page.should have_xpath("//a[@href = \"#{url_for(controller: 'downloads', action: 'show', id: object)}\"]")
      end
    end
    context "user is superuser" do
      before do
        User.any_instance.stub(:superuser?).and_return(true)
        visit catalog_index_path
        fill_in "q", :with => object.title.first
        click_button "search"
      end
      it "should discover the object" do
        page.should have_content(object.pid)
      end
    end
  end
end
