require 'spec_helper'
require 'dul_hydra'
require 'cancan/matchers'

describe Ability do

  subject { described_class.new(user) }
  let(:user) { FactoryGirl.create(:user) }
  after { user.destroy }

  describe "create permissions" do
    context "ActiveFedora::Base" do
      it { should_not be_able_to(:create, ActiveFedora::Base) }
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
        its(:can_create_models?) { should be_true }
      end
      context "user is NOT member of model creators group" do
        its(:can_create_models) { should be_empty }
        its(:can_create_models?) { should be_false }
        it "should DENY creation" do
          DulHydra.creatable_models.each do |model|
            subject.should_not be_able_to(:create, model.constantize)
          end
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

    after { obj.destroy }

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
            it { should_not be_able_to(:download, obj) }
          end

          context "and user lacks read permission" do
            it { should_not be_able_to(:download, obj) }
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
            it { should be_able_to(:download, obj) }
          end

          context "and user lacks read permission" do
            it { should_not be_able_to(:download, obj) }
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
          it { should be_able_to(:download, obj) }
        end

        context "and user lacks read permission" do
          it { should_not be_able_to(:download, obj) }
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
              it { should_not be_able_to(:download, ds) }
            end

            context "and user lacks read permission on the object" do
              it { should_not be_able_to(:download, ds) }
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
              it { should be_able_to(:download, ds) }
            end

            context "and user lacks read permission on the object" do
              it { should_not be_able_to(:download, ds) }
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
            it { should be_able_to(:download, ds) }
          end

          context "and user lacks read permission on the object" do
            it { should_not be_able_to(:download, ds) }
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
          it { should be_able_to(:download, ds) }
        end
        context "and user lacks read permission on the object" do
          it { should_not be_able_to(:download, ds) }
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
    let(:export_set) { FactoryGirl.create(:descriptive_metadata_export_set, user: user, pids: ["foo:bar"], csv_col_sep: "||") }
    context "associated user" do
      it { should be_able_to(:manage, export_set) }
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
      it { should_not be_able_to(:create, IngestFolder) }
    end
    context "user has at least one permitted ingest folder" do
      before { IngestFolder.stub(:permitted_folders).with(user).and_return(['dir']) }
      it { should be_able_to(:create, IngestFolder) }
    end
  end

  describe "#superuser_permissions" do
    before do
      DulHydra.creatable_models = ["AdminPolicy", "Collection"]
      DulHydra.stub(:superuser_group).and_return("superusers")
      user.stub(:groups).and_return(["superusers"])
    end
    it { should be_able_to(:manage, :all) }
  end

  describe "#attachment_permissions", attachments: true do
    context "object can have attachments" do
      let(:obj) { FactoryGirl.create(:test_model_omnibus) }
      after { obj.destroy }
      context "user has edit rights on attached_to object" do
        before do
          obj.edit_users = [user.user_key]
          obj.save!
        end
        it { should be_able_to(:add_attachment, obj) }
      end
      context "user lacks edit rights on attached_to object" do
        before do
          obj.read_users = [user.user_key]
          obj.save!
        end
        it { should_not be_able_to(:add_attachment, obj) }
      end
    end
    context "object cannot have attachments" do
      let(:obj) { FactoryGirl.create(:test_model) }
      after { obj.destroy }
      before do
        obj.edit_users = [user.user_key]
        obj.save!
      end
      it { should_not be_able_to(:add_attachment, obj) }
    end
  end

  describe "#children_permissions" do
    after { obj.destroy }
    context "user has edit rights on object" do
      before do
        obj.edit_users = [user.user_key]
        obj.save!
      end
      context "and object can have children" do
        let(:obj) { FactoryGirl.create(:collection) }
        it { should be_able_to(:add_children, obj) }
        it { should be_able_to(:remove_children, obj) }
        it { should be_able_to(:manage_children, obj) }
      end
      context "and object cannot have children" do
        let(:obj) { FactoryGirl.create(:component) }
        it { should_not be_able_to(:add_children, obj) }
        it { should_not be_able_to(:remove_children, obj) }
        it { should_not be_able_to(:manage_children, obj) }
      end
    end
    context "user lacks edit rights on attached_to object" do
      let(:obj) { FactoryGirl.create(:collection) }
      before do
        obj.read_users = [user.user_key]
        obj.save!
      end
      it { should_not be_able_to(:add_children, obj) }
      it { should_not be_able_to(:remove_children, obj) }
      it { should_not be_able_to(:manage_children, obj) }
    end    
  end

end
