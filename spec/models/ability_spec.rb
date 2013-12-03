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
        DulHydra.creatable_models = ["AdminPolicy", "Collection"]
        DulHydra.ability_group_map = {"AdminPolicy" => {create: "admins"}, "Collection" => {create: "collection_admins"}}.with_indifferent_access
      end
      context "user is a member of the model creators group" do
        before { user.stub(:groups).and_return(["admins", "collection_admins"]) }
        it "should permit creation" do
          DulHydra.creatable_models.each do |model|
            subject.can?(:create, model.constantize).should be_true
          end
        end
        it "should have a non-empty list of can_create_models" do
          subject.can_create_models.map{|m| m.to_s}.should == DulHydra.creatable_models
        end
        it "should return true for can_create_model? on granted models" do
          DulHydra.creatable_models.each do |model|
            subject.can_create_model?(model).should be_true
          end
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
        it "should have an empty list of can_create_models" do
          subject.can_create_models.should be_empty
        end
        it "should return false for can_create_models?" do
          subject.can_create_models?.should be_false
        end
        it "should return false for can_create_model? on all models" do
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
            it "should deny download" do
              subject.can?(:download, obj).should be_false
            end
          end

          context "and user lacks read permission" do
            it "should deny download" do
              subject.can?(:download, obj).should be_false
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
            it "should permit download" do
              subject.can?(:download, obj).should be_true
            end
          end

          context "and user lacks read permission" do
            it "should deny download" do
              subject.can?(:download, obj).should be_false
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
          it "should permit download" do
            subject.can?(:download, obj).should be_true
          end
        end

        context "and user lacks read permission" do
          it "should deny download" do
            subject.can?(:download, obj).should be_false
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
              it "should deny download" do
                subject.can?(:download, ds).should be_false
              end
            end

            context "and user lacks read permission on the object" do
              it "should deny download" do
                subject.can?(:download, ds).should be_false
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
              it "should permit download" do
                subject.can?(:download, ds).should be_true
              end
            end

            context "and user lacks read permission on the object" do
              it "should deny download" do
                subject.can?(:download, ds).should be_false
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
            it "should permit download" do
              subject.can?(:download, ds).should be_true
            end
          end

          context "and user lacks read permission on the object" do
            it "should deny download" do
              subject.can?(:download, ds).should be_false
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
          it "should permit download" do
            subject.can?(:download, ds).should be_true
          end
        end
        context "and user lacks read permission on the object" do
          it "should deny download" do
            subject.can?(:download, ds).should be_false
          end
        end        
      end

    end

  end # download_permissions

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
