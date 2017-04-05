require 'spec_helper'

RSpec.describe AddIntermediateFile, type: :service do

  let(:user) { FactoryGirl.create(:user) }
  let(:component) { FactoryGirl.create(:component) }
  let(:filepath) { Rails.root.join('spec', 'fixtures') }
  let(:intermediate_file) { 'imageA.jpg' }

  subject { described_class.new(user: user, filepath: filepath, intermediate_file: intermediate_file) }

  describe 'one matching component' do
    before { component.update_attributes(local_id: 'imageA') }
    it 'adds the intermediate file to the object' do
      subject.process
      component.reload
      expect(component.datastreams[Ddr::Datastreams::INTERMEDIATE_FILE].size).to_not be_nil
    end
    describe 'checksum' do
      describe 'no checksum provided' do
        it 'does not validate a checksum' do
          expect(component.datastreams[Ddr::Datastreams::INTERMEDIATE_FILE]).to_not receive(:validate_checksum!)
          subject.process
        end
      end
      describe 'checksum provided' do
        subject { described_class.new(user: user, filepath: filepath, intermediate_file: intermediate_file,
                                      checksum: 'abcdef') }
        it 'validates the checksum' do
          expect_any_instance_of(ActiveFedora::Datastream).to receive(:validate_checksum!) { nil }
          subject.process
        end
      end
    end
  end

  describe 'no matching component' do
    it 'raises an exception' do
      expect{ subject.process }.to raise_error(DulHydra::Error,
                                               "Unable to find Component matching local_id 'imageA' for #{intermediate_file}")
    end
  end

  describe 'multiple matching components' do
    before do
      allow(Component).to receive(:where) { [ Component.new, Component.new ] }
    end
    it 'raises an exception' do
      expect{ subject.process }.to raise_error(DulHydra::Error,
                                               "Multiple Components matching local_id 'imageA' for #{intermediate_file}")
    end
  end

end
