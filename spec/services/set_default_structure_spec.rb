require 'spec_helper'

RSpec.describe SetDefaultStructure, type: :service do

  subject { described_class.new(repo_id) }

  let(:repo_id) { 'test:1234' }

  before do
    allow(ActiveFedora::Base).to receive(:find) { object }
  end

  describe '#default_structure_needed?' do
    describe 'can have structural metadata' do
      describe 'no existing structural metadata' do
        let(:object) { double(can_have_struct_metadata?: true, has_struct_metadata?: false) }
        its(:default_structure_needed?) { is_expected.to be true }
      end
      describe 'existing structural metadata' do
        let(:object) { double(can_have_struct_metadata?: true, has_struct_metadata?: true) }
        describe 'repository maintained' do
          before { allow(object).to receive_message_chain(:structure, :repository_maintained?) { true } }
          its(:default_structure_needed?) { is_expected.to be true }
        end
        describe 'not repository maintained' do
          before { allow(object).to receive_message_chain(:structure, :repository_maintained?) { false } }
          its(:default_structure_needed?) { is_expected.to be false }
        end
      end
    end
    describe 'cannot have structural metadata' do
      let(:object) { double(can_have_struct_metadata?: false) }
      its(:default_structure_needed?) { is_expected.to be false }
    end
  end
end
