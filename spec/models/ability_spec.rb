require 'spec_helper'
require 'dul_hydra'
require 'cancan/matchers'

shared_examples "it can" do |ability|
  it "should be able to" do
    expect(subject).to be_able_to(ability, resource)
  end
end

shared_examples "it cannot" do |ability|
  it "should not be able" do
    expect(subject).not_to be_able_to(ability, resource)
  end
end

describe Ability do

  subject { described_class.new(user) }
  let(:user) { FactoryGirl.build(:user) }

  describe "#role_permissions", roles: true do
    context "when the user has a role that specifies an ability and a model" do
      before { allow(user).to receive(:role_abilities) { [[:create, Collection]] } }
      it "should have the ability on the model" do
        expect(subject).to be_able_to(:create, Collection)
      end
    end
    context "when the user has a role that specifies an ability but no model" do
      before { allow(user).to receive(:role_abilities) { [[:create, :all]] } }
      it "should have the ability on all" do
        expect(subject).to be_able_to(:create, :all)
      end
    end
  end

  describe "#upload_permissions", uploads: true do
    let!(:resource) { FactoryGirl.build(:component) }
    context "user has edit permission" do
      before { subject.can(:edit, resource) }
      it_behaves_like "it can", :upload
    end
    context "user does not have edit permission" do
      before { subject.cannot(:edit, resource) }
      it_behaves_like "it cannot", :upload
    end
  end

  describe "#download_permissions" do
    context "on an object" do
      context "which is a Component", components: true do
        let!(:resource) { FactoryGirl.create(:component) }
        context "and user does NOT have the Component Downloader role" do
          before do
            allow(subject).to receive(:has_role?).with("Component Downloader") { false }
          end
          context "and user has edit permission" do
            before { subject.can(:edit, resource) }
            it_behaves_like "it can", :download
          end
          context "and user has read permission" do
            before { subject.can(:read, resource) }
            it_behaves_like "it cannot", :download
          end
          context "and user lacks read permission" do
            before { subject.cannot(:read, resource) }
            it_behaves_like "it cannot", :download
          end
        end

        context "and user has the Component Downloader role" do
          before do
            allow(subject).to receive(:has_role?).with("Component Downloader") { true }
          end
          context "and user has edit permission" do
            before { subject.can(:edit, resource) }
            it_behaves_like "it can", :download
          end
          context "and user has read permission" do
            before { subject.can(:read, resource) }
            it_behaves_like "it can", :download
          end
          context "and user lacks read permission" do
            before { subject.cannot(:read, resource) }
            it_behaves_like "it cannot", :download
          end          
        end
      end

      context "which is not a Component" do
        let(:resource) { FactoryGirl.build(:test_content) }
        context "and user has read permission" do
          before { subject.can(:read, resource) }
          it_behaves_like "it can", :download
        end
        context "and user lacks read permission" do
          before { subject.cannot(:read, resource) }
          it_behaves_like "it cannot", :download
        end                  
      end
    end

    context "on a datastream" do

      context "named 'content'" do
        let(:resource) { obj.content }

        context "and object is a Component" do
          let(:obj) { FactoryGirl.build(:component_with_content) }
          context "and user does not have the Component Downloader role" do
            context "and user has read permission on the object" do
              before { subject.can(:read, obj.pid) }
              it_behaves_like "it cannot", :download
            end
            context "and user lacks read permission on the object" do
              before { subject.cannot(:read, obj.pid) }
              it_behaves_like "it cannot", :download
            end
          end

          context "and user has the Component Downloader role" do
            before { allow(subject).to receive(:has_role?).with("Component Downloader") { true } }
            context "and user has read permission on the object" do
              before { subject.can(:read, obj.pid) }
              it_behaves_like "it can", :download
            end
            context "and user lacks read permission on the object" do
              before { subject.cannot(:read, obj.pid) }
              it_behaves_like "it cannot", :download
            end          
          end
        end

        context "and object is not a Component" do
          let(:obj) { FactoryGirl.create(:test_content) }
          context "and user has read permission on the object" do
            before { subject.can(:read, obj.pid) }
            it_behaves_like "it can", :download
          end
          context "and user lacks read permission on the object" do
            before { subject.cannot(:read, obj.pid) }
            it_behaves_like "it cannot", :download
          end                  
        end

      end

      context "not named 'content'" do
        let(:obj) { FactoryGirl.build(:test_model) }
        let(:resource) { obj.descMetadata }
        context "and user has read permission on the object" do
          before { subject.can(:read, obj.pid) }
          it_behaves_like "it can", :download
        end
        context "and user lacks read permission on the object" do
          before { subject.cannot(:read, obj.pid) }
          it_behaves_like "it cannot", :download
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
    let(:resource) { ExportSet.new(user: user) }
    context "associated user" do
      it_behaves_like "it can", :manage
    end
    context "other user" do
      subject { described_class.new(other_user) }
      let(:other_user) { FactoryGirl.create(:user) }
      it_behaves_like "it cannot", :read
    end
  end
  
  describe "#ingest_folders_permissions" do
    let(:resource) { IngestFolder }
    context "user has no permitted ingest folders" do
      before { allow(resource).to receive(:permitted_folders).with(user).and_return([]) }
      it_behaves_like "it cannot", :create
    end
    context "user has at least one permitted ingest folder" do
      before { allow(resource).to receive(:permitted_folders).with(user).and_return(['dir']) }
      it_behaves_like "it can", :create
    end
  end

  describe "#superuser_permissions" do
    let(:resource) { :all }
    before do
      allow(DulHydra).to receive(:superuser_group).and_return("superusers")
      allow(user).to receive(:groups).and_return(["superusers"])
    end
    it_behaves_like "it can", :manage
  end

  describe "#attachment_permissions", attachments: true do
    context "object can have attachments" do
      let(:resource) { FactoryGirl.build(:test_model_omnibus) }
      context "and user lacks edit rights" do
        before { subject.cannot(:edit, resource) }
        it_behaves_like "it cannot", :add_attachment
      end
      context "and user has edit rights" do
        before { subject.can(:edit, resource) }
        it_behaves_like "it can", :add_attachment
      end
    end
    context "object cannot have attachments" do
      let(:resource) { FactoryGirl.build(:test_model) }
      before { subject.can(:edit, resource) }
      it_behaves_like "it cannot", :add_attachment
    end
  end

  describe "#children_permissions" do
    context "user has edit rights on object" do
      before { subject.can(:edit, resource) }
      context "and object can have children" do
        let(:resource) { FactoryGirl.build(:collection) }
        it_behaves_like "it can", :add_children
      end
      context "but object cannot have children" do
        let(:resource) { FactoryGirl.build(:component) }
        it_behaves_like "it cannot", :add_children
      end
    end
    context "user lacks edit rights on attached_to object" do
      let(:resource) { FactoryGirl.build(:collection) }
      before { subject.cannot(:edit, resource) }
      it_behaves_like "it cannot", :add_children
    end    
  end

end
