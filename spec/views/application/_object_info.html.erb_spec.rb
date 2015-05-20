require 'spec_helper'

RSpec.describe 'application/_object_info.html.erb', type: :view do

  before do
    allow(view).to receive(:link_to_unless_current).and_return("unneeded")
    allow(view).to receive(:current_object) { object }
  end

  describe "object create / modified dates" do
    let(:object) { FactoryGirl.build(:item) }
    before do
      allow(object).to receive(:create_date) { Time.now }
      allow(object).to receive(:modified_date) { Time.now }
      render
    end
    it "should display the object creation date" do
      expect(rendered).to match(/#{object.create_date.localtime}/)
    end
    it "should display the object modification date" do
      expect(rendered).to match(/#{object.modified_date.localtime}/)
    end
  end

  describe "permanent id" do
    let(:object) { FactoryGirl.build(:item) }
    describe "when object has a permanent id" do
      before do
        allow(object).to receive(:permanent_id) { "ark:/99999/fk4zzzzz" }
      end
      it "should display the permanent id" do
        render
        expect(rendered).to match(/ark:\/99999\/fk4zzzzz/)
      end
    end
    describe "when object does not have a permanent id" do
      it "should display the a 'not assigned' label" do
        render
        expect(rendered).to match(/Permanent ID Not Assigned/)
      end
    end
  end

  describe "published to public interface?" do
    let(:object) { FactoryGirl.build(:item) }
    context "object is published" do
      before { allow(object).to receive(:published?) { true } }
      it "should display that it's published" do
        render
        expect(rendered).to match /(?<!Not )Published/
      end
    end
    context "object is not published" do
      before { allow(object).to receive(:published?) { false } }
      it "should display that it's not published" do
        render
        expect(rendered).to match /Not Published/
      end
    end
  end

  describe "last fixity check" do
    let(:object) { FactoryGirl.build(:item) }
    context "when it has been fixity checked" do
      let(:fixity_check) { FactoryGirl.build(:fixity_check_event, pid: object.pid) }
      before { allow(object).to receive(:last_fixity_check) { fixity_check } }
      it "should display the last fixity check date" do
        render
        expect(rendered).to match(/#{fixity_check.event_date_time.localtime.to_s}/)
      end
    end
    context "when it has never been fixity checked" do
      before { allow(object).to receive(:last_fixity_check) { nil } }
      it "should display that it's not fixity checked" do
        render
        expect(rendered).to match(/Not Fixity Checked/)
      end
    end
  end

  describe "last virus check" do
    let(:object) { FactoryGirl.build(:component) }
    context "when it has been virus checked" do
      let(:virus_check) { FactoryGirl.build(:virus_check_event, pid: object.pid) }
      before { allow(object).to receive(:last_virus_check) { virus_check } }
      it "should display the last virus check date" do
        render
        expect(rendered).to match(/#{virus_check.event_date_time.localtime.to_s}/)
      end
    end
    context "when it has never been virus checked" do
      before { allow(object).to receive(:last_virus_check) { nil } }
      it "should display that it's not virus checked" do
        render
        expect(rendered).to match(/Not Virus Scanned/)
      end
    end
  end

  describe "original filename" do
    context "object can have content" do
      let(:object) { FactoryGirl.build(:component) }
      it "should display the 'Original Filename' label" do
        render
        expect(rendered).to match /Original Filename/
      end
    end
    context "object cannot have content" do
      let(:object) { FactoryGirl.build(:item) }
      it "should not display original filename" do
        render
        expect(rendered).to_not match /Original Filename/
      end
    end
  end

end
