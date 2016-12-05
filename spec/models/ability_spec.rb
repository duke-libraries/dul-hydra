require 'spec_helper'
require 'cancan/matchers'

describe Ability, type: :model, abilities: true do

  subject { described_class.new(auth_context) }

  let(:auth_context) { FactoryGirl.build(:auth_context) }

  describe "aliases" do
    it "should alias actions to :read" do
      expect(subject.aliased_actions[:read])
        .to include(:attachments, :components, :event, :events, :items, :targets, :versions, :duracloud)
    end
    it "should alias actions to :grant" do
      expect(subject.aliased_actions[:grant]).to include(:roles)
    end
    it "should alias actions to :update" do
      expect(subject.aliased_actions[:update]).to include(:admin_metadata)
    end
  end

  describe "ExportSet abilities" do
    describe "auth context is authenticated" do
      let(:resource) { FactoryGirl.create(:content_export_set_with_pids) }

      it { should be_able_to(:create, ExportSet) }
      it { should_not be_able_to(:read, resource) }

      describe "and is creator of export set" do
        before { allow(auth_context).to receive(:user) { resource.user } }
        it { should be_able_to(:manage, resource) }
      end
    end

    describe "auth context is anonymous" do
      let(:auth_context) { FactoryGirl.build(:auth_context, :anonymous) }
      it { should_not be_able_to(:create, ExportSet) }
    end
  end

  describe "IngestFolder abilities" do
    describe "user has no permitted ingest folders" do
      before { allow(IngestFolder).to receive(:permitted_folders).with(auth_context.user) { [] } }
      it { should_not be_able_to(:create, IngestFolder) }
    end

    describe "user has at least one permitted ingest folder" do
      before { allow(IngestFolder).to receive(:permitted_folders).with(auth_context.user) { ["dir"] } }
      it { should be_able_to(:create, IngestFolder) }
    end
  end

  describe "MetadataFile abilities" do
    describe "create" do
      describe "when the user is a member of the metadata file creators group" do
        before { allow(auth_context).to receive(:member_of?) { true } }
        it { should be_able_to(:create, MetadataFile) }
      end
      describe "when the user is not a member of the metadata file creators group" do
        before { allow(auth_context).to receive(:member_of?) { false } }
        it { should_not be_able_to(:create, MetadataFile) }
      end
    end

    describe "show" do
      let(:resource) { FactoryGirl.create(:metadata_file_descmd_csv) }
      describe "when the user is the creator of the MetadataFile" do
        before { allow(auth_context).to receive(:user) { resource.user } }
        it { should be_able_to(:show, resource) }
      end
      describe "when the user is not the creator of the MetadataFile" do
        it { should_not be_able_to(:show, resource) }
      end
    end

    describe "procezz" do
      let(:resource) { FactoryGirl.create(:metadata_file_descmd_csv) }
      describe "when the user is the creator of the MetadataFile" do
        before { allow(auth_context).to receive(:user) { resource.user } }
        it { should be_able_to(:procezz, resource) }
      end
      describe "when the user is not the creator of the MetadataFile" do
        it { should_not be_able_to(:procezz, resource) }
      end
    end
  end

  describe "SimpleIngest abilities" do
    let(:resource) { SimpleIngest.new({ "folder_path" => '/foo', "batch_user" => auth_context.user.user_key }) }
    before { auth_context.user.save! }
    describe "create" do
      before { allow_any_instance_of(described_class).to receive(:can?).and_call_original }
      describe "when the user can create collections" do
        before { allow_any_instance_of(described_class).to receive(:can?).with(:create, Collection) { true } }
        it { should be_able_to(:create, resource) }
      end
      describe "when the user cannot create collections" do
        before { allow_any_instance_of(described_class).to receive(:can?).with(:create, Collection) { false } }
        it { should_not be_able_to(:create, resource) }
      end
    end
    describe "show" do
      describe "when the user is the creator of the SimpleIngest" do
        it { should be_able_to(:show, resource) }
      end
      describe "when the user is not the creator of the SimpleIngest" do
        before { resource.user = FactoryGirl.build(:user) }
        it { should_not be_able_to(:show, resource) }
      end
    end
  end

end
