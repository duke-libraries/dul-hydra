require 'spec_helper'
require 'cancan/matchers'

describe Ability, type: :model, abilities: true do

  subject { described_class.new(user) }
  let(:user) { FactoryGirl.create(:user) }

  describe "#export_sets_permissions", export_sets: true do
    let(:resource) { ExportSet.new(user: user) }
    context "associated user" do
      it { is_expected.to be_able_to(:manage, resource) }
    end
    context "other user" do
      subject { described_class.new(other_user) }
      let(:other_user) { FactoryGirl.create(:user) }
      it { is_expected.not_to be_able_to(:read, resource) }
    end
  end

  describe "#ingest_folders_permissions", ingest_folders: true do
    let(:resource) { IngestFolder }
    context "user has no permitted ingest folders" do
      before { allow(resource).to receive(:permitted_folders).with(user).and_return([]) }
      it { is_expected.not_to be_able_to(:create, resource) }
    end
    context "user has at least one permitted ingest folder" do
      before { allow(resource).to receive(:permitted_folders).with(user).and_return(['dir']) }
      it { is_expected.to be_able_to(:create, resource) }
    end
  end

end
