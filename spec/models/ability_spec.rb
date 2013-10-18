require 'spec_helper'
require 'dul_hydra'

describe Ability do

  describe "#download_permissions" do
    let(:user) { FactoryGirl.create(:user) }
    let(:ability) { described_class.new(user) }
    after do
      user.delete 
      obj.delete
    end
    context "ActiveFedora::Base object datastream" do
      let(:obj) { FactoryGirl.create(:test_model) }
      context "user has read permission" do
        before do
          obj.read_users = [user.user_key]
          obj.save
        end
        it "should grant download permission to the user" do
          ability.can?(:download, obj.descMetadata).should be_true
        end
      end
      context "user lacks read permission" do
        before do
          obj.rightsMetadata.clear_permissions!
          obj.save
        end
        it "should deny download permission to the user" do
          ability.can?(:download, obj.descMetadata).should be_false
        end
      end
    end
    context "Component `content' datastream" do
      let(:obj) { FactoryGirl.create(:component) }
      context "user lacks read permission" do
        before do
          DulHydra.component_download_group = "foo:bar"
          obj.rightsMetadata.clear_permissions!
          obj.save
        end
        context "user is member of download group" do
          it "should grant download permission to the user" do
            user.stub(:groups).and_return(["foo:bar"])
            ability.can?(:download, obj.datastreams[DulHydra::Datastreams::CONTENT]).should be_true
          end
        end
        context "user is not member of download group" do
          it "should deny download permission to the user" do
            user.stub(:groups).and_return(["spam:eggs"])
            ability.can?(:download, obj.datastreams[DulHydra::Datastreams::CONTENT]).should be_false
          end
        end
      end      
    end
  end

  describe "#discover_permissions" do
  end

  describe "#preservation_events_permissions" do
  end

  describe "#export_sets_permissions" do
  end

end
