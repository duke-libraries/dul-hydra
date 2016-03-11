require 'spec_helper'
require 'cancan/matchers'

describe Ability, type: :model, abilities: true do

  subject { described_class.new(auth_context) }

  let(:auth_context) { FactoryGirl.build(:auth_context) }

  describe "aliases" do
    it "should alias actions to :read" do
      expect(subject.aliased_actions[:read])
        .to include(:attachments, :components, :event, :events, :items, :targets, :versions)
    end
    it "should alias actions to :grant" do
      expect(subject.aliased_actions[:grant]).to include(:roles)
    end
    it "should alias actions to :update" do
      expect(subject.aliased_actions[:update]).to include(:admin_metadata)
    end
    it "should alias actions to :audit" do
      expect(subject.aliased_actions[:audit]).to include(:report)
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
      let(:collection) { Collection.new(id: 'ab/cd/ef/abcdefgh') }
      let(:resource) { MetadataFile.new(collection_pid: collection.id) }
      before { allow(subject).to receive(:can?).and_call_original }

      describe "when the user can ingest metadata for the collection" do
        before { allow(subject).to receive(:can?).with(:ingest_metadata, collection.id) { true } }
        it { should be_able_to(:create, resource) }
      end
      describe "when the user cannot ingest metadata for the collection" do
        before { allow(subject).to receive(:can?).with(:ingest_metadata, collection.id) { false } }
        it { should_not be_able_to(:create, resource) }
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

  describe "METSFolder abilities" do
    describe "create" do
      let(:collection) { Collection.new(id: 'ab/cd/ef/abcdefgh') }
      let(:resource) { METSFolder.new(collection_id: collection.id) }
      before { allow(subject).to receive(:can?).and_call_original }

      describe "when the user can ingest metadata for the collection" do
        before { allow(subject).to receive(:can?).with(:ingest_metadata, collection.id) { true } }
        it { should be_able_to(:create, resource) }
      end
      describe "when the user cannot ingest metadata for the collection" do
        before { allow(subject).to receive(:can?).with(:ingest_metadata, collection.id) { false } }
        it { should_not be_able_to(:create, resource) }
      end
    end

    describe "show" do
      let(:user) { FactoryGirl.build(:user) }
      let(:resource) { METSFolder.new(user: user) }
      describe "when the user is the creator of the METSFolder" do
        before { allow(auth_context).to receive(:user) { resource.user } }
        it { should be_able_to(:show, resource) }
      end
      describe "when the user is not the creator of the METSFolder" do
        it { should_not be_able_to(:show, resource) }
      end
    end

    describe "procezz" do
      let(:user) { FactoryGirl.build(:user) }
      let(:resource) { METSFolder.new(user: user) }
      describe "when the user is the creator of the METSFolder" do
        before { allow(auth_context).to receive(:user) { resource.user } }
        it { should be_able_to(:procezz, resource) }
      end
      describe "when the user is not the creator of the METSFolder" do
        it { should_not be_able_to(:procezz, resource) }
      end
    end
  end

end
