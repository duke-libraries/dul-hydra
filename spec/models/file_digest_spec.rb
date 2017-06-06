RSpec.describe FileDigest do

  subject { described_class.new(path: file.path, repo_id: "test:1", file_id: "content") }

  let(:file) { fixture_file_upload('sample.pdf') }

  let(:sha1) { 'a6ae0d815c1a2aef551b45fe34a35ceea1828a4d' }
  let(:md5) { '4f3f9c99a9f2720b77870371ff21ea9f' }

  describe ".generate_sha1" do
    specify {
      expect(described_class.generate_sha1(file.path)).to eq sha1
    }
  end

  describe "#generate_sha1" do
    specify {
      expect(subject.generate_sha1(file.path)).to eq sha1
    }
  end

  describe ".generate_md5" do
    specify {
      expect(described_class.generate_md5(file.path)).to eq md5
    }
  end

  describe "#generate_md5" do
    specify {
      expect(subject.generate_md5(file.path)).to eq md5
    }
  end

  describe "set_digests" do
    before do
      subject.set_digests
    end
    its(:sha1) { is_expected.to eq sha1 }
    its(:md5) { is_expected.to eq md5 }
  end

end
