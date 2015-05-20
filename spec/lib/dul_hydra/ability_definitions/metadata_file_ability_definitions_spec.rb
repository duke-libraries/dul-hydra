require 'spec_helper'
require 'cancan/matchers'

module DulHydra
  RSpec.describe MetadataFileAbilityDefinitions do

    subject { described_class.call(ability) }

    let(:ability) { FactoryGirl.build(:abstract_ability) }

    describe "create" do
      before { allow(DulHydra).to receive(:metadata_file_creators_group) { "MetadataFileCreators" } }
      describe "when the user is a member of the metadata file creators group" do
        before { allow(ability).to receive(:member_of?).with("MetadataFileCreators") { true } }
        it { should be_able_to(:create, MetadataFile) }
      end
      describe "when the user is not a member of the metadata file creators group" do
        before { allow(ability).to receive(:member_of?).with("MetadataFileCreators") { false } }
        it { should_not be_able_to(:create, MetadataFile) }
      end
    end

    describe "show" do
      let(:resource) { FactoryGirl.create(:metadata_file_descmd_csv) }
      describe "when the user is the creator of the MetadataFile" do
        before { allow(ability).to receive(:user) { resource.user } }
        it { should be_able_to(:show, resource) }
      end
      describe "when the user is not the creator of the MetadataFile" do
        it { should_not be_able_to(:show, resource) }
      end
    end

    describe "procezz" do
      let(:resource) { FactoryGirl.create(:metadata_file_descmd_csv) }
      describe "when the user is the creator of the MetadataFile" do
        before { allow(ability).to receive(:user) { resource.user } }
        it { should be_able_to(:procezz, resource) }
      end
      describe "when the user is not the creator of the MetadataFile" do
        it { should_not be_able_to(:procezz, resource) }
      end
    end

  end
end
