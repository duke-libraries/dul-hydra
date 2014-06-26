require 'spec_helper'

describe Role do
  let(:role) { Role.new(name: "Test Role") }
  describe "#to_s" do
    it "should render the name" do
      expect(role.to_s).to eq("Test Role")
    end
  end
  describe "#groups_string" do
    before { role.groups = ["Foo", "Bar"] }
    it "should concat the groups with commas" do
      expect(role.groups_string).to eq("Foo, Bar")
    end
  end
  describe "#groups_text" do
    before { role.groups = ["Foo", "Bar"] }
    it "should concat the groups with line breaks" do
      expect(role.groups_text).to eq("Foo\nBar")
    end
  end
  describe "users_string" do
    before { role.users = FactoryGirl.build_list(:user, 3) }
    it "should concat the users (rendered as strings) with commas" do
      expect(role.users_string).to eq(role.users.map(&:to_s).join(", "))
    end
  end
  describe "#ability_params" do
    context "when ability is present" do
      before do
        role.ability = "create"
        role.model = "Collection"
      end
      it "should return a tuple" do
        expect(role.ability_params).to eq([:create, Collection])
      end
    end
    context "when ability is not present" do
      it "should return nil" do
        expect(role.ability_params).to be_nil
      end
    end
  end
  describe "#ability_class" do
    context "when model is present" do
      before { role.model = "Collection" }
      it "should return the class for the model" do
        expect(role.ability_class).to eq(Collection)
      end
    end
    context "when model is not present" do
      it "should return :all" do
        expect(role.ability_class).to eq(:all)
      end
    end
  end
  describe "#nil_if_blank" do
    before do
      role.model = ""
      role.ability = ""
    end
    it "should set model and ability to nil if blank before validation" do
      expect(role).to be_valid
      expect(role.model).to be_nil
      expect(role.ability).to be_nil
    end
  end
  describe "#normalize_groups" do
    before { role.groups = "Foo\nBar" }
    it "should split on line breaks before validation if groups is a string" do
      expect(role).to be_valid
      expect(role.groups).to match_array(["Foo", "Bar"])
    end
  end
end
