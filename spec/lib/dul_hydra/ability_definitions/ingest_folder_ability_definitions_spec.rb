require 'spec_helper'
require 'cancan/matchers'

module DulHydra
  RSpec.describe IngestFolderAbilityDefinitions do

    subject { described_class.call(ability) }

    let(:ability) { FactoryGirl.build(:abstract_ability) }

    describe "user has no permitted ingest folders" do
      before { allow(IngestFolder).to receive(:permitted_folders).with(ability.user) { [] } }
      it { should_not be_able_to(:create, IngestFolder) }
    end

    describe "user has at least one permitted ingest folder" do
      before { allow(IngestFolder).to receive(:permitted_folders).with(ability.user) { ["dir"] } }
      it { should be_able_to(:create, IngestFolder) }
    end

  end
end
