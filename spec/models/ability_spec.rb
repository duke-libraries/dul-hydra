require 'spec_helper'
require 'dul_hydra'
require 'cancan/matchers'

describe Ability do

  subject { described_class.new(user) }
  let(:user) { FactoryGirl.create(:user) }
  after do
    User.destroy_all
    ActiveFedora::Base.destroy_all
  end

  describe "#role_permissions", roles: true do
    after { Role.destroy_all }
    let!(:role) do
      Role.new.tap do |role|
        role.name = "Manager"
        role.model = "Collection"
        role.ability = "create"
        role.user_ids = [user.id]
        role.save
      end
    end
    context "role specifies an ability and a model" do
      it "should have that ability on that model" do
        expect(subject).to be_able_to(:create, Collection)
      end
    end
    context "role specifies an ability but no model" do
      before do
        role.model = nil
        role.save
      end
      it "should have the ability on all models" do
        expect(subject).to be_able_to(:create, :all)
      end
    end
  end

  describe "#upload_permissions", uploads: true do
    let(:obj) { FactoryGirl.build(:component_with_content) }
    context "user has edit permission" do
      before { subject.can(:edit, obj) }
      it { should be_able_to(:upload, obj) }
    end
    context "user does not have edit permission" do
      before { subject.cannot(:edit, obj) }
      it { should_not be_able_to(:upload, obj) }
    end
  end

  describe "#download_permissions" do
    context "on an object" do
      context "which is a Component", components: true do
        let(:obj) { FactoryGirl.create(:component_with_content) }
        context "and user does NOT have the Component Downloader role" do
          context "and user has edit permission" do
            before { subject.can(:edit, obj) }
            it { should be_able_to(:download, obj) }
          end
          context "and user has read permission" do
            before { subject.can(:read, obj) }
            it { should_not be_able_to(:download, obj) }
          end
          context "and user lacks read permission" do
            before { subject.cannot(:read, obj) }
            it { should_not be_able_to(:download, obj) }
          end
        end

        context "and user has the Component Downloader role" do
          before do
            allow(subject).to receive(:has_role?).with("Component Downloader") { true }
          end
          context "and user has edit permission" do
            before { subject.can(:edit, obj) }
            it { should be_able_to(:download, obj) }
          end
          context "and user has read permission" do
            before { subject.can(:read, obj) }
            it { should be_able_to(:download, obj) }
          end
          context "and user lacks read permission" do
            before { subject.cannot(:read, obj) }
            it { should_not be_able_to(:download, obj) }
          end          
        end
      end

      context "which is not a Component" do
        let(:obj) { FactoryGirl.create(:test_content) }
        context "and user has read permission" do
          before { subject.can(:read, obj) }
          it { should be_able_to(:download, obj) }
        end
        context "and user lacks read permission" do
          before { subject.cannot(:read, obj) }
          it { should_not be_able_to(:download, obj) }
        end                  
      end
    end

    context "on a datastream" do

      context "named 'content'" do
        let(:ds) { obj.content }

        context "and object is a Component" do
          let(:obj) { FactoryGirl.build(:component_with_content) }
          context "and user does not have the Component Downloader role" do
            context "and user has read permission on the object" do
              before { subject.can(:read, obj.pid) }
              it { should_not be_able_to(:download, ds) }
            end
            context "and user lacks read permission on the object" do
              before { subject.cannot(:read, obj.pid) }
              it { should_not be_able_to(:download, ds) }
            end
          end

          context "and user has the Component Downloader role" do
          before { allow(subject).to receive(:has_role?).with("Component Downloader") { true } }
            before { user.stub(:groups).and_return(["component_download"]) }
            context "and user has read permission on the object" do
              before { subject.can(:read, obj.pid) }
              it { should be_able_to(:download, ds) }
            end
            context "and user lacks read permission on the object" do
              before { subject.cannot(:read, obj.pid) }
              it { should_not be_able_to(:download, ds) }
            end          
          end
        end

        context "and object is not a Component" do
          let(:obj) { FactoryGirl.create(:test_content) }
          context "and user has read permission on the object" do
            before { subject.can(:read, obj.pid) }
            it { should be_able_to(:download, ds) }
          end
          context "and user lacks read permission on the object" do
            before { subject.cannot(:read, obj.pid) }
            it { should_not be_able_to(:download, ds) }
          end                  
        end

      end

      context "not named 'content'" do
        let(:obj) { FactoryGirl.build(:test_model) }
        let(:ds) { obj.descMetadata }
        context "and user has read permission on the object" do
          before { subject.can(:read, obj.pid) }
          it { should be_able_to(:download, ds) }
        end
        context "and user lacks read permission on the object" do
          before { subject.cannot(:read, obj.pid) }
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
    let(:export_set) do
      ExportSet.new.tap do |es|
        es.export_type = ExportSet::Types::DESCRIPTIVE_METADATA
        es.user = user
        es.pids = ["foo:bar"]
        es.csv_col_sep = "double pipe"
      end
    end
    context "associated user" do
      it { should be_able_to(:manage, export_set) }
    end
    context "other user" do
      let(:other_user) { FactoryGirl.create(:user) }
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
      DulHydra.stub(:superuser_group).and_return("superusers")
      user.stub(:groups).and_return(["superusers"])
    end
    it { should be_able_to(:manage, :all) }
  end

  describe "#attachment_permissions", attachments: true do
    context "object can have attachments" do
      let(:obj) { FactoryGirl.build(:test_model_omnibus) }
      context "and user lacks edit rights" do
        before { subject.cannot(:edit, obj) }
        it { should_not be_able_to(:add_attachment, obj) }
      end
      context "and user has edit rights" do
        before { subject.can(:edit, obj) }
        it { should be_able_to(:add_attachment, obj) }
      end
    end
    context "object cannot have attachments" do
      let(:obj) { FactoryGirl.build(:test_model) }
      before { subject.can(:edit, obj) }
      it { should_not be_able_to(:add_attachment, obj) }
    end
  end

  describe "#children_permissions" do
    context "user has edit rights on object" do
      before { subject.can(:edit, obj) }
      context "and object can have children" do
        let(:obj) { FactoryGirl.build(:collection) }
        it { should be_able_to(:add_children, obj) }
      end
      context "and object cannot have children" do
        let(:obj) { FactoryGirl.build(:component) }
        it { should_not be_able_to(:add_children, obj) }
      end
    end
    context "user lacks edit rights on attached_to object" do
      let(:obj) { FactoryGirl.build(:collection) }
      before { subject.cannot(:edit, obj) }
      it { should_not be_able_to(:add_children, obj) }
    end    
  end

end
