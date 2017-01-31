require 'spec_helper'

module DulHydra::Batch::Scripts

  RSpec.describe AddIntermediateFiles do

    let(:user_key) { 'tom@school.edu' }
    let(:filepath) { '/file/path' }
    let(:dir_entries) { [ '.', '..', '.DS_Store', 'file01.jpg', 'file02.jpg', 'file03.jpg', 'checksums.txt', 'README' ] }

    subject { described_class.new(batch_user: user_key, filepath: filepath) }

    before do
      allow(User).to receive(:find_by_user_key) { double('User', user_key: user_key) }
      allow(Dir).to receive(:entries).with(filepath) { dir_entries }
    end

    it 'should enqueue a job for each file' do
      expect(Resque).to receive(:enqueue).with(AddIntermediateFileJob, user: user_key, filepath: filepath, intermediate_file: 'file01.jpg')
      expect(Resque).to receive(:enqueue).with(AddIntermediateFileJob, user: user_key, filepath: filepath, intermediate_file: 'file02.jpg')
      expect(Resque).to receive(:enqueue).with(AddIntermediateFileJob, user: user_key, filepath: filepath, intermediate_file: 'file03.jpg')
      subject.execute
    end

  end

end

