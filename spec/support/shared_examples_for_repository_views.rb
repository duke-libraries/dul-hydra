def setup
  object.read_users = [user.user_key]
  object.save
  login_as user
end

def teardown
  User.destroy_all
  ActiveFedora::Base.destroy_all
  EventLog.destroy_all
  Warden.test_reset!
end

shared_examples "a repository object show view" do
  let(:user) { FactoryGirl.create(:user) }
  before { setup }
  after { teardown }
  describe "object summary" do
    before { visit url_for(object) }
    it "should display the title" do
      expect(find("#object-title")).to have_content(object.title_display)
    end
    it "should display the thumbnail" do
      expect(page).to have_css("#object-thumbnail img.img-thumbnail")
    end
    it "should display the PID" do
      expect(find("#object-summary")).to have_content(object.pid)
    end
  end
  describe "object info" do
    before { visit url_for(object) }
    it "should display the object creation date" do
      expect(find("#object-info")).to have_content("Created")
    end
    it "should display the object modification date" do
      expect(find("#object-info")).to have_content("Modified")
    end
  end
  describe "tools" do
    it "should have bookmark toggle control"
  end
  describe "descriptive metadata" do
    let(:tab) { "#tab_descriptive_metadata" }
    it "should display the descriptive metadata" do
      visit url_for(object)
      expect(page).to have_css(tab)
    end
    it "should have a link to download the XML" do
      visit url_for(object)
      expect(find(tab)).to have_link("Download XML")
    end
    context "when the user can edit the object" do
      before do
        object.edit_users = [user.user_key]
        object.save
      end
      it "should link to the edit view" do
        visit url_for(object)
        expect(find(tab)).to have_link("Edit")
      end
    end
    context "when the user cannot edit the object" do
      it "should not link to the edit view" do
        visit url_for(object)
        expect(find(tab)).not_to have_link("Edit")
      end
    end
  end
  describe "rights metadata" do
    let(:tab) { "#tab_permissions" }
    it "should display the rights metadata" do
      visit url_for(object)
      expect(find(tab)).to have_content("Access Controls")
      expect(find(tab)).to have_content("License")
      expect(find(tab).find("tr.access-level-read")).to have_content(user.to_s)
    end
    it "should have a link to download the XML" do
      visit url_for(object)
      expect(find(tab)).to have_link("Download XML")
    end
    context "when the user can edit the object" do
      before do
        object.edit_users = [user.user_key]
        object.save
      end
      it "should link to the edit view" do
        visit url_for(object)
        expect(find(tab)).to have_link("Modify")
      end
    end
    context "when the user cannot edit the object" do
      it "should not link to the edit view" do
        visit url_for(object)
        expect(find(tab)).not_to have_link("Modify")
      end
    end
  end
  describe "events" do
    let(:tab) { "#tab_preservation_events" }
    before do
      object.fixity_check!
      object.reload
    end
    it "should display the last fixity check" do
      visit url_for(object)
      expect(find("#object-info")).to have_content("Fixity Check")
    end
    it "should display the events" do
      visit url_for(object)
      expect(page).to have_css(tab)
    end
  end
end

shared_examples "a content-bearing object show view" do
  let(:user) { FactoryGirl.create(:user) }
  before do
    setup
    # required for Components
    allow(DulHydra).to receive(:ability_group_map) { {"Component" => {download: "downloaders"}}.with_indifferent_access }
    allow(user).to receive(:groups) { ["public", "registered", "downloaders"] }
  end
  after { teardown }
  it "should have a download link" do
    pending
    visit url_for(object)
    expect(page).to have_link("download-#{object.safe_id}", href: url_for(controller: 'downloads', action: 'show', id: object))
  end
  context "when the user can edit the object" do
    before do
      object.edit_users = [user.user_key]
      object.save
    end
    it "should have an upload link" do
      pending
      visit url_for(object)
      expect(page).to have_link("upload-content-link", href: url_for(controller: object.controller_name, action: 'upload', id: object))
    end
  end
  context "when the user cannot edit the object" do
    it "should not have an upload link" do
      pending
      visit url_for(object)
      expect(page).not_to have_link("upload-content-link", href: url_for(controller: object.controller_name, action: 'upload', id: object))
    end
  end
end

shared_examples "a repository object rights editing view" do
  let(:user) { FactoryGirl.create(:user) }
  before do
    object.edit_users = [user.user_key]
    object.read_groups = ["registered"]
    object.discover_groups = ["public"]
    object.license_title = "Wide Open"
    object.license_description = "Anyone can do anything"
    object.save
    login_as user
  end
  after { teardown }
  it "should be idempotent" do
    original_permissions = object.permissions
    visit url_for(controller: object.controller_name, action: "permissions", id: object)
    click_button "Save"
    object.reload
    expect(object.permissions).to eq(original_permissions)
    expect(object.edit_users).to eq([user.user_key])
    expect(object.read_groups).to eq(["registered"])
    expect(object.discover_groups).to eq(["public"])
    expect(object.license_title).to eq("Wide Open")
    expect(object.license_description).to eq("Anyone can do anything")
  end
  it "should be able to remove a permission" do
    visit url_for(controller: object.controller_name, action: "permissions", id: object)
    page.unselect "Public", from: "permissions_discover"
    click_button "Save"
    object.reload
    expect(object.discover_groups).to be_empty
  end
  it "should be able to add a permission" do
    visit url_for(controller: object.controller_name, action: "permissions", id: object)
    page.select "Duke Community", from: "permissions_edit"
    click_button "Save"
    object.reload
    expect(object.edit_groups).to eq(["registered"])
  end
  it "should be able to modify the license" do
    visit url_for(controller: object.controller_name, action: "permissions", id: object)
    fill_in "license_title", with: "No Access"
    fill_in "license_description", with: "No one can get to it"
    click_button "Save"
    object.reload
    expect(object.license_title).to eq("No Access")
    expect(object.license_description).to eq("No one can get to it")
  end
end