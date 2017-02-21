RSpec.describe FileDigest do

  let(:file) { fixture_file_upload('sample.pdf') }

  describe "generate_sh1" do
    specify {
      expect(described_class.generate_sha1(file.path)).to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d"
    }
    specify {
      expect(subject.generate_sha1(file.path)).to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d"
    }
  end

  describe "generate_md5" do
    specify {
      expect(described_class.generate_md5(file.path)).to eq "4f3f9c99a9f2720b77870371ff21ea9f"
    }
    specify {
      expect(subject.generate_md5(file.path)).to eq "4f3f9c99a9f2720b77870371ff21ea9f"
    }
  end

  describe "set_digests" do
    before do
      subject.set_digests(file.path)
    end
    its(:md5) { is_expected.to eq "4f3f9c99a9f2720b77870371ff21ea9f" }
    its(:sha1) { is_expected.to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d" }
  end

end
