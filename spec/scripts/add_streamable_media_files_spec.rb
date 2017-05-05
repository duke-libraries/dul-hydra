require 'spec_helper'

module DulHydra::Batch::Scripts

  RSpec.describe AddStreamableMediaFiles do

    let(:user_key) { 'tom@school.edu' }
    let(:filepath) { '/file/path' }
    let(:dir_entries) { [ '.', '..', '.DS_Store', 'file01.mp3', 'file02.mp4', 'file03.mp4', 'checksums.txt', 'README' ] }
    let(:checksum_file) { Tempfile.new('checksums') }

    subject { described_class.new(batch_user: user_key, filepath: filepath, checksum_file: checksum_file.path) }

    before do
      allow(User).to receive(:find_by_user_key) { double('User', user_key: user_key) }
      allow(Dir).to receive(:entries).with(filepath) { dir_entries }
      checksum_file.puts("ghijkl #{File.join(filepath, 'file01.mp3')}")
      checksum_file.puts("stuvwx #{File.join(filepath, 'file03.mp4')}")
      checksum_file.puts("yzabcd #{File.join(filepath, 'notes.txt')}")
      checksum_file.puts("efghij #{File.join(filepath, 'README')}")
      checksum_file.close
    end

    it 'should enqueue a job for each file' do
      expect(AddStreamableMediaFileJob).to receive(:perform_later)
                                               .with(user: user_key, filepath: filepath,
                                                     streamable_media_file: 'file01.mp3', checksum: 'ghijkl')
      expect(AddStreamableMediaFileJob).to receive(:perform_later)
                                               .with(user: user_key, filepath: filepath,
                                                     streamable_media_file: 'file02.mp4', checksum: nil) { nil }
      expect(AddStreamableMediaFileJob).to receive(:perform_later)
                                               .with(user: user_key, filepath: filepath,
                                                     streamable_media_file: 'file03.mp4', checksum: 'stuvwx') { nil }
      subject.execute
    end

  end

end

