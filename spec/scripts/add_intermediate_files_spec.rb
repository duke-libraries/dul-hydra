require 'spec_helper'

module DulHydra::Batch::Scripts

  RSpec.describe AddIntermediateFiles do

    let(:user_key) { 'tom@school.edu' }
    let(:filepath) { '/file/path' }
    let(:dir_entries) { [ '.', '..', '.DS_Store', 'file01.jpg', 'file02.jpg', 'file03.jpg', 'checksums.txt', 'README' ] }
    let(:checksum_file) { Tempfile.new('checksums') }

    subject { described_class.new(batch_user: user_key, filepath: filepath, checksum_file: checksum_file.path) }

    before do
      allow(User).to receive(:find_by_user_key) { double('User', user_key: user_key) }
      allow(Dir).to receive(:entries).with(filepath) { dir_entries }
      checksum_file.puts("ghijkl #{File.join(filepath, 'file01.jpg')}")
      checksum_file.puts("stuvwx #{File.join(filepath, 'file03.jpg')}")
      checksum_file.puts("yzabcd #{File.join(filepath, 'notes.txt')}")
      checksum_file.puts("efghij #{File.join(filepath, 'README')}")
      checksum_file.close
    end

    it 'should enqueue a job for each file' do
      expect(Resque).to receive(:enqueue).with(AddIntermediateFileJob, user: user_key, filepath: filepath,
                                               intermediate_file: 'file01.jpg', checksum: 'ghijkl')
      expect(Resque).to receive(:enqueue).with(AddIntermediateFileJob, user: user_key, filepath: filepath,
                                               intermediate_file: 'file02.jpg', checksum: nil)
      expect(Resque).to receive(:enqueue).with(AddIntermediateFileJob, user: user_key, filepath: filepath,
                                               intermediate_file: 'file03.jpg', checksum: 'stuvwx')
      subject.execute
    end

  end

end

