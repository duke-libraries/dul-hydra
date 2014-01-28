require 'spec_helper'
require 'dul_hydra'
require 'cancan/matchers'

describe Ability do

  subject { described_class.new(user) }
  let(:user) { FactoryGirl.create(:user) }
  after { user.delete }

  describe "create permissions" do
    context "ActiveFedora::Base" do
      it "should DENY creation" do
        subject.should_not be_able_to(:create, ActiveFedora::Base)
      end
    end
    context "creatable models" do
      before do
        DulHydra.creatable_models = ["AdminPolicy", "Collection"]
        DulHydra.ability_group_map = {"AdminPolicy" => {create: "admins"}, "Collection" => {create: "collection_admins"}}.with_indifferent_access
      end
      context "user is a member of the model creators group" do
        before { user.stub(:groups).and_return(["admins", "collection_admins"]) }
        it "should PERMIT creation" do
          DulHydra.creatable_models.each do |model|
            subject.should be_able_to(:create, model.constantize)
          end
        end
        it "should have a non-empty list of can_create_models" do
          subject.can_create_models.map{|m| m.to_s}.should == DulHydra.creatable_models
        end
        it "should return true for :can_create_model? on granted models" do
          DulHydra.creatable_models.each do |model|
            subject.can_create_model?(model).should be_true
          end
        end
        it "should return true for :can_create_models?" do
          subject.can_create_models?.should be_true
        end
      end
      context "user is NOT member of model creators group" do
        it "should DENY creation" do
          DulHydra.creatable_models.each do |model|
            subject.should_not be_able_to(:create, model.constantize)
          end
        end
        it "should have an empty list of :can_create_models" do
          subject.can_create_models.should be_empty
        end
        it "should return false for :can_create_models?" do
          subject.can_create_models?.should be_false
        end
        it "should return false for :can_create_model? on all models" do
          DulHydra.creatable_models.each do |model|
            subject.can_create_model?(model).should be_false
          end
        end
      end
    end
  end

  describe "#download_permissions" do

    after { obj.delete }

    context "object" do

      context "is a Component" do
        let(:obj) { FactoryGirl.create(:component_with_content) }
        before { DulHydra.ability_group_map = {"Component" => {download: "component_download"}}.with_indifferent_access }
        context "user is NOT a member of the component download ability group" do

          context "and user has read permission" do
            before do
              obj.read_users = [user.to_s]
              obj.save
            end
            it "should DENY download" do
              subject.should_not be_able_to(:download, obj)
            end
          end

          context "and user lacks read permission" do
            it "should DENY download" do
              subject.should_not be_able_to(:download, obj)
            end            
          end
        end

        context "user is a member of the component download ability group" do
          before do
            user.stub(:groups).and_return(["component_download"])
          end

          context "and user has read permission" do
            before do
              obj.read_users = [user.to_s]
              obj.save
            end
            it "should PERMIT download" do
              subject.should be_able_to(:download, obj)
            end
          end

          context "and user lacks read permission" do
            it "should DENY download" do
              subject.should_not be_able_to(:download, obj)
            end            
          end          
        end
      end

      context "is not a Component" do
        let(:obj) { FactoryGirl.create(:test_content) }

        context "and user has read permission" do
          before do
            obj.read_users = [user.to_s]
            obj.save
          end
          it "should PERMIT download" do
            subject.should be_able_to(:download, obj)
          end
        end

        context "and user lacks read permission" do
          it "should DENY download" do
            subject.should_not be_able_to(:download, obj)
          end            
        end                  
      end
    end

    context "datastream" do

      context "content" do
        let(:ds) { obj.content }

        context "object is a Component" do
          let(:obj) { FactoryGirl.create(:component_with_content) }
          before { DulHydra.ability_group_map = {"Component" => {download: "component_download"}}.with_indifferent_access }
          context "user is NOT a member of the component download ability group" do

            context "and user has read permission on the object" do
              before do
                obj.read_users = [user.to_s]
                obj.save
              end
              it "should DENY download" do
                subject.should_not be_able_to(:download, ds)
              end
            end

            context "and user lacks read permission on the object" do
              it "should DENY download" do
                subject.should_not be_able_to(:download, ds)
              end            
            end
          end

          context "user is a member of the component download ability group" do
            before do
              user.stub(:groups).and_return(["component_download"])
            end

            context "and user has read permission on the object" do
              before do
                obj.read_users = [user.to_s]
                obj.save
              end
              it "should PERMIT download" do
                subject.should be_able_to(:download, ds)
              end
            end

            context "and user lacks read permission on the object" do
              it "should DENY download" do
                subject.should_not be_able_to(:download, ds)
              end            
            end          
          end
        end

        context "object is not a Component" do
          let(:obj) { FactoryGirl.create(:test_content) }

          context "and user has read permission on the object" do
            before do
              obj.read_users = [user.to_s]
              obj.save
            end
            it "should PERMIT download" do
              subject.should be_able_to(:download, ds)
            end
          end

          context "and user lacks read permission on the object" do
            it "should DENY download" do
              subject.should_not be_able_to(:download, ds)
            end            
          end                  
          
        end

      end

      context "not content" do
        let(:obj) { FactoryGirl.create(:test_model) }
        let(:ds) { obj.descMetadata }
        context "and user has read permission on the object" do
          before do
            obj.read_users = [user.to_s]
            obj.save
          end
          it "should PERMIT download" do
            subject.should be_able_to(:download, ds)
          end
        end
        context "and user lacks read permission on the object" do
          it "should DENY download" do
            subject.should_not be_able_to(:download, ds)
          end
        end        
      end

    end

  end # download_permissions

  describe "#discover_permissions" do
    # TODO
  end

  describe "#preservation_events_permissions" do
    # TODO
  end

  describe "#export_sets_permissions", export_sets: true do
    let(:export_set) { FactoryGirl.create(:descriptive_metadata_export_set, user: user, pids: ["foo:bar"]) }
    context "associated user" do
      it "should PERMIT :manage" do
        subject.should be_able_to(:manage, export_set)
      end
    end
    context "other user" do
      let(:other_user) { FactoryGirl.create(:user) }
      after { other_user.delete }
      it "should DENY :read access" do
        described_class.new(other_user).should_not be_able_to(:read, export_set)
      end
    end
  end
  
  describe "#ingest_folders_permissions" do
    context "user has no permitted ingest folders" do
      before { IngestFolder.stub(:permitted_folders).with(user).and_return([]) }
      it "should DENY create permission to the user" do
        subject.should_not be_able_to(:create, IngestFolder)
      end      
    end
    context "user has at least one permitted ingest folder" do
      before { IngestFolder.stub(:permitted_folders).with(user).and_return(['dir']) }
      it "should PERMIT create permission to the user" do
        subject.should be_able_to(:create, IngestFolder)
      end      
    end
  end

  describe "#superuser_permissions" do
    before do
      DulHydra.creatable_models = ["AdminPolicy", "Collection"]
      DulHydra.stub(:superuser_group).and_return("superusers")
      user.stub(:groups).and_return(["superusers"])
    end
    it "should grant :manage on :all" do
      subject.should be_able_to(:manage, :all)
    end
  end

  describe "#attachment_permissions", attachments: true do
    let(:obj) { FactoryGirl.create(:test_model) }
    after { obj.destroy }
    context "user has edit rights on attached_to object" do
      #before { subject.stub(:can?, [:edit, TestModel]).and_return(true) }
      before do
        obj.edit_users = [user.user_key]
        obj.save!
      end
      it "should be able add an attachment" do
        subject.should be_able_to(:add_attachment, obj)
      end
    end
    context "user lacks edit rights on attached_to object" do
      #before { subject.stub(:can?, [:edit, TestModel]).and_return(false) }
      before do
        obj.read_users = [user.user_key]
        obj.save!
      end
      it "should be able add an attachment" do
        subject.should_not be_able_to(:add_attachment, obj)
      end
    end
  end

end
