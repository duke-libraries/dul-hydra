require 'spec_helper'

RSpec.describe UpdateParentStructure, type: :service do

  subject { described_class.new(object_id, parent_id) }

  let(:object_id) { 'test:1234' }
  let(:parent_id) { 'test:999' }

  describe ".call" do
    let(:notification_args) { [ 'test', DateTime.now - 2.seconds, DateTime.now - 1.seconds, 'testid', payload ] }
    let(:payload) { { pid: object_id, parent: parent_id, skip_structure_updates: skip_parent_update } }
    around do |example|
      prev_auto_update_parent_structure = DulHydra.auto_update_parent_structure
      example.run
      DulHydra.auto_update_parent_structure = prev_auto_update_parent_structure
    end
    describe "auto update parent structure" do
      before { DulHydra.auto_update_parent_structure = true }
      describe "skip parent structure updating" do
        let(:skip_parent_update) { true }
        it "does not update the parent's structure" do
          expect_any_instance_of(UpdateParentStructure).to_not receive(:run)
          UpdateParentStructure.call(*notification_args)
        end
      end
      describe "do not skip parent structure updating" do
        let(:skip_parent_update) { false }
        it "updates the parent's structure" do
          expect_any_instance_of(UpdateParentStructure).to receive(:run)
          UpdateParentStructure.call(*notification_args)
        end
      end
    end
    describe "do not auto update parent structure" do
      before { DulHydra.auto_update_parent_structure = false }
      describe "do not skip parent structure updating" do
        let(:skip_parent_update) { false }
        it "updates the parent's structure" do
          expect_any_instance_of(UpdateParentStructure).to_not receive(:run)
          UpdateParentStructure.call(*notification_args)
        end
      end
    end
  end

  describe "#run" do
    describe "object does not have a parent" do
      let(:parent_id) { nil }
      it "does not update parent's structure" do
        expect(subject).to_not receive(:calculate_parent_structure)
        subject.run
      end
    end
    describe "object has a parent" do
      it "updates parent's structure" do
        expect(subject).to receive(:calculate_parent_structure).with(parent_id)
        subject.run
      end
    end
  end
end
