require 'spec_helper'
require 'dul_hydra'

describe Ability do

  subject { described_class.new(user) }
  let(:user) { FactoryGirl.create(:user) }

  after { user.delete }

  describe "create permissions" do
    context "ActiveFedora::Base" do
      it "should NOT permit creation" do
        subject.can?(:create, ActiveFedora::Base).should be_false
      end
    end
    context "creatable models" do
      before do
        DulHydra.creatable_models = ["AdminPolicy", "Collection", "Item"]
        DulHydra.groups = {admin_policy_creators: "admins", collection_creators: "collection_admins", item_creators: "item_creators"}.with_indifferent_access
      end
      context "user is a member of the model creators group" do
        before { user.stub(:groups).and_return(DulHydra.groups.values) }
        it "should permit creation" do
          DulHydra.creatable_models.each do |model|
            subject.can?(:create, model.constantize).should be_true
          end
        end
        it "should have a non-empty list of creatable models" do
          subject.creatable_models.should == DulHydra.creatable_models
        end
        it "should return true for can_create_models?" do
          subject.can_create_models?.should be_true
        end
      end
      context "user is NOT member of model creators group" do
        it "should not permit creation" do
          DulHydra.creatable_models.each do |model|
            subject.can?(:create, model.constantize).should be_false
          end
        end
        it "should have an empty list of creatable models" do
          subject.creatable_models.should be_empty
        end
        it "should return false for can_create_models?" do
          subject.can_create_models?.should be_false
        end
      end
    end
  end

  describe "#download_permissions" do
    after { obj.delete }
    context "ActiveFedora::Base object datastream" do
      let(:obj) { FactoryGirl.create(:test_model) }
      context "user has read permission" do
        before do
          obj.read_users = [user.user_key]
          obj.save
        end
        it "should grant download permission to the user" do
          subject.can?(:download, obj.descMetadata).should be_true
        end
      end
      context "user lacks read permission" do
        before do
          obj.rightsMetadata.clear_permissions!
          obj.save
        end
        it "should deny download permission to the user" do
          subject.can?(:download, obj.descMetadata).should be_false
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
            subject.can?(:download, obj.datastreams[DulHydra::Datastreams::CONTENT]).should be_true
          end
        end
        context "user is not member of download group" do
          it "should deny download permission to the user" do
            user.stub(:groups).and_return(["spam:eggs"])
            subject.can?(:download, obj.datastreams[DulHydra::Datastreams::CONTENT]).should be_false
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
  
  describe "#ingest_folders_permissions" do
    context "user has no permitted ingest folders" do
      before { IngestFolder.stub(:permitted_folders).with(user).and_return([]) }
      it "should deny create permission to the user" do
        subject.can?(:create, IngestFolder).should be_false
      end      
    end
    context "user has at least one permitted ingest folder" do
      before { IngestFolder.stub(:permitted_folders).with(user).and_return(['dir']) }
      it "should allow create permission to the user" do
        subject.can?(:create, IngestFolder).should be_true
      end      
    end
  end

end
